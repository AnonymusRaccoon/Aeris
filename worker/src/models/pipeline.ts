export enum ServiceType {
	Twitter,
	Youtube,
	Github,
	Spotify,
	Discord,
	Anilist,
};


export enum PipelineType {
	// Special value that will never emit an action. It is used for deleted pipelines.
	Never,
	OnTweet,

	OnYtUpload,
	OnYtLike,
	OnYtPlaylistAdd,

	OnOpenPR,
	OnCommentPR,
	OnClosePR,
	OnMergePR,
	OnCreateIssue,
	OnCommentIssue,
	OnCloseIssue,
	OnForkRepo,
	OnStarRepo,
	OnWatchRepo,
	OnSpotifyAddToPlaylist,
	OnSpotifySaveToLibrary,

	OnDiscordMessage,
	OnDiscordMessageFrom,
	OnDiscordMention,
	OnNewDiscordGuildMember,
	OnDiscordGuildLeave,
};

export enum ReactionType {
	Tweet,
	// Youtube reactions
	YtLike,
	YtComment,
	YtAddToPlaylist,
	// Github reactions
	OpenPR,
	CommentPR,
	ClosePR,
	MergePR,
	CreateIssue,
	CommentIssue,
	CloseIssue,
	CreateRepo,
	CreatePrivateRepo,
	UpdateDescription,
	ForkRepo,
	StarRepo,
	WatchRepo,
	//Spotify reaction
	PlayTrack,
	AddTrackToLibrary,
	AddToPlaylist,
	//Discord
	SetDiscordStatus,
	PostDiscordDM,
	LeaveDiscordServer,
	PostDiscordMessage,
	Pause,
	// Anilist
	ToggleFavourite,
	followUser,
	postTweet,
	replyToTweet,
	likeTweet,
	retweet
};

export class Pipeline {
	id: number;
	service: ServiceType;
	type: PipelineType;
	name: string;
	params: {[key: string]: string};
	enabled: boolean;
	userId: number;
	userData: {[key: string]: Token};
	reactions: [Reaction];
};

export class Token {
	accessToken: string;
	refreshToken: string;
	expiresIn: string;
};

export class Reaction {
	service: ServiceType;
	type: ReactionType;
	params: {[key: string]: any};
};

export class PipelineEnv {
	[key: string]: any;
};

export const pipelineFromApi = (data: any): Pipeline => {
	const type: string = data.res.action.pType;
	return {
		id: data.res.action.id,
		name: data.res.action.name,
		service: ServiceType[type.substring(0, type.indexOf('_')) as keyof typeof ServiceType],
		type: PipelineType[type.substring(type.indexOf('_') + 1) as keyof typeof PipelineType],
		params: data.res.action.pParams,
		enabled: data.res.action.enabled,

		reactions: data.res.reactions.map((x: any) => ({
			params: x.rParams,
			service: ServiceType[x.rType.substring(0, x.rType.indexOf('_')) as keyof typeof ServiceType],
			type: ReactionType[x.rType.substring(x.rType.indexOf('_') + 1) as keyof typeof ReactionType],
		})),

		userId: data.userData.userId,
		userData: Object.fromEntries(data.userData.tokens.map((x: any) => [
			x.service,
			{
				accessToken: x.accessToken,
				refreshToken: x.refreshToken,
				expiresIn: x.expiresIn
			} as Token
		])),
	};
}
