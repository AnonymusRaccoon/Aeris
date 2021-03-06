import { API_ROUTE, AppServices } from "./globals";
import { AppAREAType, AppPipelineType, AppServiceType, ParamsType, AlertLevel } from "./types";
import { useTranslation } from "react-i18next";

export function setCookie(cname: string, cvalue: string, exdays: number): void {
	const d = new Date();
	d.setTime(d.getTime() + exdays * 24 * 60 * 60 * 1000);
	let expires = "expires=" + d.toUTCString();
	document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

export function getCookie(cname: string): string {
	let name = cname + "=";
	let decodedCookie = decodeURIComponent(document.cookie);
	let ca = decodedCookie.split(";");
	for (let i = 0; i < ca.length; i++) {
		let c = ca[i].trim();
		if (c.indexOf(name) == 0) {
			return c.substring(name.length, c.length);
		}
	}
	return "";
}

export const sendServiceAuthToken = async (
	authToken: string,
	serviceEndpoint: string,
	redirectUri: string
): Promise<boolean> => {
	const response = await fetch(`${API_ROUTE}${serviceEndpoint}?code=${authToken}&redirect_uri=${redirectUri}`, {
		method: "GET",
		headers: {
			Authorization: "Bearer " + getCookie("aeris_jwt"),
		},
	});

	return response.ok;
};

export const signInService = async (
	authToken: string,
	serviceEndpoint: string,
	redirectUri: string
): Promise<boolean> => {
	const response = await fetch(`${API_ROUTE}${serviceEndpoint}?code=${authToken}&redirect_uri=${redirectUri}`, {
		method: "POST",
		headers: {
			Accept: 'application/json',
			"Content-Type": "application/json"
		}
	});

	if (!response.ok) return false;
	let json = await response.json();
	setCookie("aeris_jwt", json['jwt'], 365);
	return response.ok;
};

export const PipelineParamsToApiParam = (pipelineParams: { [key: string]: ParamsType }) => {
	return Object.fromEntries(Object.entries(pipelineParams).map((el) => [el[0], el[1].value]));
};

export const PipeLineHostToApi = (pipelineData: AppPipelineType) => {
	return {
		action: {
			id: 69,
			name: pipelineData.name,
			enabled: pipelineData.data.enabled,
			pType: pipelineData.action.type,
			pParams: PipelineParamsToApiParam(pipelineData.action.params),
		},
		reactions: pipelineData.reactions.map((reac) => {
			return {
				rType: reac.type,
				rParams: PipelineParamsToApiParam(reac.params),
			};
		}),
	};
};

const deSerializeAREAParams = (dumpAREAParam: Array<any>): { [key: string]: ParamsType } => {
	let params: { [key: string]: ParamsType } = {};
	dumpAREAParam.forEach((el) => {
		params[el.name] = {
			value: "",
			type: el.type,
			description: el.description,
		};
	});
	return params;
};

const deSerializeAREAReturns = (dumpAREAReturns: Array<any>): { [key: string]: { [key: string]: string } } => {
	let returns: { [key: string]: { [key: string]: string } } = {};
	dumpAREAReturns.forEach((el) => {
		returns[el.name] = el.description;
	});
	return returns;
};

export const deSerializeAREA = (dumpAREA: any, service: AppServiceType): AppAREAType => {
	return {
		type: dumpAREA.name,
		description: dumpAREA.description,
		service: service,
		label: dumpAREA.label,
		params: deSerializeAREAParams(dumpAREA.params),
		returns: deSerializeAREAReturns(dumpAREA.returns),
	};
};

export const deSerializeService = (dumpService: any, services: Array<AppServiceType>): Array<Array<AppAREAType>> => {
	let service: AppServiceType = services.find((el) => el.uid === dumpService.name.toLowerCase()) ?? services[0];

	let actions: Array<AppAREAType> = dumpService.actions.map((el: any) => deSerializeAREA(el, service));
	let reactions: Array<AppAREAType> = dumpService.reactions.map((el: any) => deSerializeAREA(el, service));

	return [actions, reactions];
};

export const deSerializeServices = (
	dumpServices: Array<any>,
	services: Array<AppServiceType>
): Array<Array<AppAREAType>> => {
	let actions: Array<AppAREAType> = [];
	let reactions: Array<AppAREAType> = [];

	dumpServices.forEach((serviceData) => {
		let newAREAs = deSerializeService(serviceData, services);
		actions = actions.concat(newAREAs[0]);
		reactions = reactions.concat(newAREAs[1]);
	});
	return [actions, reactions];
};

export const deSerializeApiPipelineAction = (data: any, actions: Array<AppAREAType>): AppAREAType => {
	const refAction = actions.filter((el) => el.type === data.pType);

	let params: { [key: string]: ParamsType } = refAction[0].params;
	Object.entries(data.pParams as { [key: string]: string }).forEach((paramData) => {
		if (!(paramData[0] in params)) return;
		params[paramData[0]].value = paramData[1];
	});

	return {
		...refAction[0],
		params: params,
	};
};

export const deSerializeApiPipelineReaction = (data: any, refReaction: AppAREAType): AppAREAType => {
	let params: { [key: string]: ParamsType } = refReaction.params;
	Object.entries(data.rParams as { [key: string]: string }).forEach((paramData) => {
		if (!(paramData[0] in params)) return;
		params[paramData[0]].value = paramData[1];
	});

	return {
		...refReaction,
		params: params,
	};
};

export const deSerializePipeline = (data: any, AREAs: Array<Array<AppAREAType>>): AppPipelineType => {
	let reactionList: AppAREAType[] = [];
	for (const reaction of data.reactions) {
		const refReaction = deepCopy(AREAs[1].filter((el) => el.type === reaction.rType)[0]);
		if (refReaction !== undefined) reactionList.push(deepCopy(deSerializeApiPipelineReaction(reaction, refReaction)));
	}

	return {
		id: data["action"]["id"],
		name: data["action"]["name"],
		action: deepCopy(deSerializeApiPipelineAction(data.action, AREAs[0])),
		reactions: reactionList,
		data: {
			enabled: data.action.enabled,
			caBeEnabled: true,
			alertLevel: data.action.error !== null ? AlertLevel.Error : AlertLevel.None,
			lastTrigger: data.action.lastTrigger === null ? undefined : new Date(data.action.lastTrigger),
			triggerCount: data.action?.triggerCount ?? 0,
			status: data.action.error !== null ? data.action.error : "",
		},
	} as AppPipelineType;
};

export const fetchWorkflows = async (): Promise<any> => {
	const response = await fetch(API_ROUTE + "/workflows", {
		method: "GET",
		headers: {
			Accept: "application/json",
			"Content-Type": "application/json",
			Authorization: "Bearer " + getCookie("aeris_jwt"),
		},
	});

	if (response.ok) {
		let json = await response.json();
		return json;
	}
	console.error("Can't fetch newer workflows");
	return null;
};

export const fetchLinkedServices = async (): Promise<Array<string>> => {
	const response = await fetch(API_ROUTE + "/auth/services", {
		method: "GET",
		headers: {
			Accept: "application/json",
			"Content-Type": "application/json",
			Authorization: "Bearer " + getCookie("aeris_jwt"),
		},
	});

	if (response.ok) {
		let json = await response.json();
		return json;
	}
	console.error("Can't fetch linked services");
	return [];
};

export const generateRandomString = (): string => {
	let randomString = "";
	const randomNumber = Math.floor(Math.random() * 10);

	for (let i = 0; i < 20 + randomNumber; i++) {
		randomString += String.fromCharCode(33 + Math.floor(Math.random() * 94));
	}
	return randomString;
};

export const unLinkService = async (service: AppServiceType): Promise<boolean> => {
	let route = service.urlAuth.slice(0, service.urlAuth.indexOf("?"));
	route = route.slice(0, route.lastIndexOf("/"));

	const response = await fetch(route, {
		method: "DELETE",
		headers: {
			Accept: "application/json",
			"Content-Type": "application/json",
			Authorization: "Bearer " + getCookie("aeris_jwt"),
		},
	});

	return response.ok;
};

export const deepCopy = (obj: any): any => {
	if (typeof obj !== "object" || obj === null) {
		return obj;
	}

	if (obj instanceof Date) {
		return new Date(obj.getTime());
	}

	if (obj instanceof Array) {
		return obj.reduce((arr, item, i) => {
			arr[i] = deepCopy(item);
			return arr;
		}, []);
	}

	if (obj instanceof Object) {
		return Object.keys(obj).reduce((newObj: any, key) => {
			newObj[key] = deepCopy(obj[key]);
			return newObj;
		}, {});
	}
};

export const doesPipelineUseService = (pD: AppPipelineType, service: AppServiceType): boolean => {
	const sUid = service.uid;

	if (pD.action.service.uid === sUid) return true;
	for (const rea of pD.reactions) {
		if (rea.service.uid === sUid) return true;
	}
	return false;
};

export const lintPipeline = (pD: AppPipelineType, services: Array<AppServiceType>): AppPipelineType => {
	//const { t } = useTranslation();
	pD.data.caBeEnabled = true;
	for (const svc of services) {
		if (!svc.linked && doesPipelineUseService(pD, svc)) {
			pD.data.alertLevel = AlertLevel.Warning;
			pD.data.caBeEnabled = false;
			pD.data.status = "no " + svc.label + " account";
			//	t("pipeline_missing_service_account_part_1") + svc.label + t("pipeline_missing_service_account_part_2");
		}
	}
	return pD;
};
