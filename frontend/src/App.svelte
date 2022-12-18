<script>
        import { authenticated as authenticatedStore } from "./stores.js"
        import LoginModalHandler from "./LoginModalHandler.svelte"
        import Modal from "svelte-simple-modal"
        import ModalContent from "./ModalContent.svelte"
        import axios from "axios"
        axios.defaults.baseURL = window.location.pathname
        let targetLink = "example.com"
        let authenticated = false
        let linkList = []
        const tableIntervalHandler = () => {
                if (!authenticated) {
                        return
                }
                axios.get("/api/links")
                        .then((res) => {
                                console.log(res)
                                linkList = res.data.links
                        })
                        .catch((error) => {})
        }
        authenticatedStore.subscribe((value) => {
                authenticated = value
                tableIntervalHandler()
        })

        axios.get("/api/private")
                .then((res) => {
                        authenticatedStore.set(true)
                })
                .catch((error) => {
                        authenticatedStore.set(false)
                })

        const handleChildEvent = (event) => {
          tableIntervalHandler()
        }
        // An ultra heretical line of code preventing svelte modals from overwriting body style
        setInterval(() => {setInterval(document.body.style = "")}, 500)

</script>

<main>
        <h1>PotatoLink</h1>
        <label for="target" style="font-size: 25px">Please enter the address you would like to shorten</label>
        <input bind:value={targetLink} type="text" id="target" name="target" style="width: 100%; text-align: center; font-size: 28px; margin-top: 5%; margin-bottom: 5%; border-radius: 25px;" />
        <div />
        <Modal><ModalContent text={targetLink} on:reloadTable={handleChildEvent}/></Modal>
        <Modal><LoginModalHandler /></Modal>
        {#if authenticated == true}
                <table style="margin-top: 10%; width: 80%">
                        <b>Created links:</b>
                        <tr>
                                <th>access link</th>
                                <th>target link</th>
                                <th>expiry date</th>
                        </tr>
                        {#each linkList as link}
                                <tr>
                                        <td><a href="{window.location.origin}/{link[0]}">{window.location.origin}/{link[0]}</a></td>
                                        <td><a href="{link[1]}">{link[1].length > 50 ? link[1].substring(0,50) + "..." : link[1]}</a></td>
                                        <td>{link[2]}</td>
                                </tr>
                        {/each}
                </table>
        {/if}
</main>



<style>
</style>
