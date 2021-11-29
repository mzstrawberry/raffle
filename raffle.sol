pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

contract Raffle is VRFConsumerBase, KeeperCompatibleInterface {

    uint256 public s_entranceFee = 10 gwei;
    address public s_recentWinner;
    address payable[] public s_players;
    enum State {Open, Calculating}
    State public s_state;
    uint256 public s_lastUpKeep;

    // VRF
    address _linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address _vrfCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B;
    bytes32 _keyHash =  0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    uint256 _chainlinkFee = 0.1 * 10 ** 18; // 0.1 LINK
    

    constructor() VRFConsumerBase( _vrfCoordinator, _linkToken  )  {}

    function enterRaffle() public payable {
        require( s_state == State.Open , "The raffle is currently closed." );
        require(msg.value == s_entranceFee, "Please send 10 gwei.");
        s_players.push(payable(msg.sender));
    }

    function checkUpkeep(bytes calldata /*Checkdata*/) public view override returns (
        bool upkeepNeeded, bytes memory performData
    ) {
        bool hasLink = LINK.balanceOf(address(this)) >= _chainlinkFee;
        bool isOpen = s_state == State.Open;
        bool isTime = (block.timestamp - s_lastUpKeep) > 1 hours;
        bool enoughPlayers = s_players.length > 1;
        upkeepNeeded = hasLink && isOpen && isTime && enoughPlayers;
        // upkeepNeeded = hasLink && isOpen;
    }

    function performUpkeep(bytes calldata /*performData*/) external override {
        s_state = State.Calculating;
        require( LINK.balanceOf(address(this)) >= _chainlinkFee, "You need more link.");
        requestRandomness(_keyHash, _chainlinkFee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        uint256 randomWinner = randomness % s_players.length;
        address payable winner = s_players[randomWinner];
        s_recentWinner = winner;
        (bool success,) = winner.call{value:address(this).balance}("");
        require(success, "Transfer to winner failed");

        // reset raffle
        delete s_players;
        s_state = State.Open;
    }

    function status() public view returns (uint256, uint256) {
        return (
            address(this).balance,
            s_players.length
        );
    }

}

