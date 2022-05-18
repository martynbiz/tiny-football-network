// import * as nakamajs from "@heroiclabs/nakama-js";
// import {Match, MatchData, MatchPresenceEvent, Presence} from "@heroiclabs/nakama-js/socket"

export default function rpcHealthcheck(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string): string {
    logger.info("healthcheck rpc called");
    return JSON.stringify({success: true});
}