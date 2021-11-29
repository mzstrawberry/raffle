
// connect to Moralis server
const serverUrl = "https://bihz3xirvlmd.usemoralis.com:2053/server";
const appId = "x6w3CkmtpkU678dIhyYLRXiRDyYahEelPrheaNu5";
Moralis.start({ serverUrl, appId });

// add from here down
async function login() {
    let user = Moralis.User.current();
    if (!user) {
        user = await Moralis.authenticate();
        $("#btn-login").hide();
        $("#btn-logout").show();

        $("#enter-raffle").show();

    } 
}
async function logOut() {
    await Moralis.User.logOut();
    $("#btn-login").show();
    $("#btn-logout").hide();
}


// document.getElementById("btn-fund").onclick = loadEntry;

document.getElementById("btn-login").onclick = login;
document.getElementById("btn-logout").onclick = logOut;




