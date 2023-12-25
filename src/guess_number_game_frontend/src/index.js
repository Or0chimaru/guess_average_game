// import { guess_number_game_backend } from "../../declarations/guess_number_game_backend";

import {
    createActor,
    guess_number_game_backend,
} from "../../declarations/guess_number_game_backend";

import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

let actor = guess_number_game_backend;

console.log("process.env.CANISTER_ID_INTERNET_IDENTITY : ");
console.log(process.env.CANISTER_ID_INTERNET_IDENTITY);

const whoAmIButton = document.getElementById("whoAmI");

whoAmIButton.onclick = async (e) => {
    e.preventDefault();
    whoAmIButton.setAttribute("disabled", true);
    const principal = await actor.whoami();
    whoAmIButton.removeAttribute("disabled");
    document.getElementById("principal").innerText = principal.toString() === "2vxsx-fae" ? "You are not logged in yet." : "You have already logged in. Your principal ID is: " + principal.toString();
    return false;
};

const loginButton = document.getElementById("login");

loginButton.onclick = async (e) => {
    e.preventDefault();
    let authClient = await AuthClient.create();
    // start the login process and wait for it to finish
    await new Promise((resolve) => {
        authClient.login({
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? "https://identity.ic0.app"
                    : `http://localhost:4943/?canisterId=rdmx6-jaaaa-aaaaa-aaadq-cai`,
            onSuccess: resolve,
        });
    });
    const identity = authClient.getIdentity();
    const agent = new HttpAgent({ identity });
    actor = createActor(process.env.CANISTER_ID_GUESS_NUMBER_GAME_BACKEND, {
        agent,
    });
    return false;
};

const submitButton = document.getElementById('submit_btn');

submitButton.onclick = async (e) => {
    e.preventDefault();
    const input = document.getElementById('guessInput');
    const value = parseInt(input.value);
    console.log(value);
    submitButton.setAttribute("disabled", true);
    await actor.makeOneGuess(value);
    submitButton.removeAttribute("disabled");
}
