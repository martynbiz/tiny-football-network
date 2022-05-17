let InitModule: nkruntime.InitModule = function (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, initializer: nkruntime.Initializer) {
    
    initializer.registerRpc('healthcheck', rpcHealthcheck);
    initializer.registerRpc('get_match_id', rpcGetMatchId);

    logger.info("Hello World!");

    initializer.registerMatch("match_control", match);
}