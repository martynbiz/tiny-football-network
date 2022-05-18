import rpcHealthcheck from './healthcheck'
import { rpcGetMatchId } from './match_rpc'
import { match } from './match_control'

let InitModule: nkruntime.InitModule = function (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, initializer: nkruntime.Initializer) {

    initializer.registerRpc('healthcheck', rpcHealthcheck);
    initializer.registerRpc('get_match_id', rpcGetMatchId);

    initializer.registerMatch("match_control", match);

    logger.info("Hello World!");
}

// Reference InitModule to avoid it getting removed on build
!InitModule && InitModule.bind(null);