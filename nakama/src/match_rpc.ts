export function rpcGetMatchId(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string): string {
    const matches: nkruntime.Match[] = nk.matchList(1);
    const currentMatch = matches[0]

    if (typeof currentMatch == "undefined") {
        const matchId = nk.matchCreate("match_control", { "invited": matches })
        return JSON.stringify(matchId);
    } else {
        return JSON.stringify(currentMatch.matchId);
    }
}