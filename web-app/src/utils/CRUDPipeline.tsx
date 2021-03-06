import { AppPipelineType } from "./types";
import { getCookie, PipeLineHostToApi } from "./utils";
import { API_ROUTE } from "./globals";

export const requestCreatePipeline = async (pipelineData: AppPipelineType, creation: boolean): Promise<number> => {
	const jwt = getCookie("aeris_jwt");

	const request = API_ROUTE + "/workflow/" + (!creation ? pipelineData.id : "");

	const rawResponse = await fetch(request, {
		method: creation ? "POST" : "PUT",
		headers: {
			Accept: "application/json",
			"Content-Type": "application/json",
			Authorization: "Bearer " + jwt,
		},
		body: JSON.stringify(PipeLineHostToApi(pipelineData)),
	});

	let data = await rawResponse.json();
	return rawResponse.ok ? data.action?.id ?? -2 : -1;
};

export const deletePipeline = async (pipelineData: AppPipelineType): Promise<boolean> => {
	const jwt = getCookie("aeris_jwt");

	const request = API_ROUTE + "/workflow/" + pipelineData.id;

	const rawResponse = await fetch(request, {
		method: "DELETE",
		headers: {
			Accept: "application/json",
			"Content-Type": "application/json",
			Authorization: "Bearer " + jwt,
		},
	});
	return rawResponse.ok;
};

export const getAboutJson = async (): Promise<any> => {
	const rawResponse = await fetch(API_ROUTE + "/about.json");
	if (!rawResponse.ok) return {};
	let json = await rawResponse.json();
	return json ?? {};
};
