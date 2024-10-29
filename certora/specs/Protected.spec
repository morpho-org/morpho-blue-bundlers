// SPDX-License-Identifier: GPL-2.0-or-later
using Constants as constants;

methods {
    function initiator() external returns(address) envfree;
    function MORPHO() external returns(address) envfree;
    function constants.UNSET_INITIATOR() external returns(address) envfree;
}


rule protectedMethodsComplete(method f, env e, calldataarg data) filtered {
    f -> !f.isView && !f.isFallback && f.selector != sig:multicall(bytes[]).selector
}
{
    require e.msg.sender != constants.UNSET_INITIATOR();
    require e.msg.sender != initiator();
    require e.msg.sender != MORPHO();
    f@withrevert(e,data);
    assert lastReverted;
}
