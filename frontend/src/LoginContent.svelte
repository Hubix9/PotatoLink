<script>
        import { authenticated as authenticatedStore } from "./stores.js"
        import { getContext } from "svelte"
        import axios from "axios"
	axios.defaults.baseURL = window.location.pathname
        import WhateverModal from "./whateverModal.svelte"
        const { open } = getContext("simple-modal")
        let loginUsername = ""
        let loginPassword = ""

        let registerEmail = ""
        let registerUsername = ""
        let registerPassword = ""

        const showModal = (text) => {
                open(WhateverModal, { text: text })
        }
        const showLoginThanks = () => {
                axios.post("/api/login", { username: loginUsername, password: loginPassword })
                        .then((res) => {
                                console.log(res.data)
				showModal("Login successfull!")
				authenticatedStore.set(true)
                        })
                        .catch((error) => {
                                console.log(error)
				showModal("An error during login occured")
                        })
                
        }
        const showRegistrationThanks = () => {
                axios.post("/api/register", { username: registerUsername, password: registerPassword, email: registerEmail})
                        .then((res) => {
                                console.log(res.data)
				showModal("Thank you for registering a new account! You can now login")
                        })
                        .catch((error) => {
                                console.log(error)
				showModal("An error occured during registration")
                        })
        }

</script>

<div style="row">
        <div class="column">
                <p>Login</p>
                <div>
                        <label for="usernameLogin" class="foolabel">username:</label>
                        <input type="text" id="usernameLogin" name="usernameLogin" bind:value={loginUsername}/>
                </div>
                <br />
                <div>
                        <label for="passwordLogin" class="foolabel">password:</label>
                        <input type="password" id="passwordLogin" name="passwordLogin" bind:value={loginPassword} />
                </div>
                <br />
                <button on:click={showLoginThanks}>Sign in</button>
        </div>
        <div class="column">
                <p>Register</p>
                <div>
                        <label for="email" class="foolabel">email:</label>
                        <input type="text" id="email" name="email" bind:value={registerEmail} />
                </div>
                <br />
                <div>
                        <label for="username" class="foolabel">username:</label>
                        <input type="text" id="username" name="username" bind:value={registerUsername} />
                </div>
                <br />
                <div>
                        <label for="password" class="foolabel">password:</label>
                        <input type="password" id="password" name="password" bind:value={registerPassword} />
                </div>
                <br />
                <button on:click={showRegistrationThanks}>Sign up</button>
        </div>
</div>

<style>
        .column {
                float: left;
                width: 50%;
                text-align: center;
        }

        /* Clear floats after the columns */
        .row:after {
                content: "";
                display: table;
                clear: both;
        }
        .foolabel {
                width: 10em;
                text-align: left;
                display: inline-block;
                margin-right: 1em;
        }
</style>
