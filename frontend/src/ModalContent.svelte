<script>
	export let text = "example.com";
	import { getContext } from "svelte";
	import { createEventDispatcher } from 'svelte';
	import Content from "./Content.svelte";
	import axios from "axios";
	axios.defaults.baseURL = window.location.pathname
	const dispatch = createEventDispatcher();
	const { open } = getContext("simple-modal");
	const showModal = () => {
		axios.post("/api/link", { target: text })
			.then((res) => {
				console.log(res.data);
				let access_id = res.data;
				dispatch("reloadTable")
				open(Content, {
					created_url: `${window.location.host}/${access_id}`,
				});
				
			})
			.catch((error) => {
				console.log(error);
				open(Content, {
					created_url: `Invalid url`,
				});
			});
	};
</script>

<button on:click={showModal}>Shorten link</button>
