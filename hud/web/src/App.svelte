<script>
	import Hud from "./components/Hud.svelte";
	import { visibility } from "./store/stores";
	import { onMount } from "svelte";

	visibility.set(true);

	let hudData = {
		playerid: 1,
		cash: 0,
		bank: 0,
		blackmoney: 0,
		job: "unemployed",
		playerName: "John Doe",
	};

	onMount(() => {
		window.addEventListener("message", (event) => {
			if (event.data.action === "updatehud") {
				const data = event.data[1];
				hudData = { ...hudData, ...data }; //updates hud with new data.
			}
		});
	});
</script>

<Hud
	playerName={hudData.playerName}
	playerid={hudData.playerid}
	job={hudData.job}
	cash={hudData.cash}
	bank={hudData.bank}
	blackmoney={hudData.blackmoney}
/>
