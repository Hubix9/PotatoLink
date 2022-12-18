<script>
        import { getContext } from "svelte"
        import { authenticated as authenticatedStore } from "./stores.js"
        let authenticated = false
        import LoginContent from "./LoginContent.svelte"
        import axios from "axios"
	axios.defaults.baseURL = window.location.pathname
        const { open } = getContext("simple-modal")
        const showModal = () => {
                open(LoginContent)
        }
        authenticatedStore.subscribe((value) => {
                authenticated = value
        })

        const logout = () => {
                axios.get("/logout").then((res) => {
                        console.log(res)
			authenticatedStore.set(false)
                })
        }
</script>

{#if authenticated == true}
        <a on:click={logout} href="#" style="position: absolute; top:25px; right: 50px">Logout</a>
{:else}
        <a on:click={showModal} href="#" style="position: absolute; top:25px; right: 50px">Log in / Register</a>
{/if}
