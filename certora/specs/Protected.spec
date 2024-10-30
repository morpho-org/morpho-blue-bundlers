// SPDX-License-Identifier: GPL-2.0-or-later
methods {
    function initiator() external returns(address) envfree;
    function MORPHO() external returns(address) envfree;
}


// Check that all methods except those noted below comply with the `protected` modifier when an initiator has been set.
rule protectedWithSetInitiator(method f, env e, calldataarg data) filtered {
    // Do not check view functions.
    // Do not check the fallback function.
    // Do not check multicall, which is used to start a new bundle.
    f -> !f.isView && !f.isFallback && f.selector != sig:multicall(bytes[]).selector
}
{
    f@withrevert(e,data);
    bool reverted = lastReverted;
    assert e.msg.sender != initiator() && e.msg.sender != MORPHO() => reverted;
}
