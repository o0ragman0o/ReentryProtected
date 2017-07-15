pragma solidity ^0.4.10;

import "https://github.com/o0ragman0o/ReentryProtected/ReentryProtected.sol";

contract RETests is ReentryProtected {
    
    event Reentered();
    
    function unprotectedTarget()
    {
        Reentered();
    }
    
    function protectedTarget()
        noReentry
    {
        Reentered();
    }
    
    function noProtection() {
        this.unprotectedTarget();
        this.protectedTarget();
    }
    
    function withProtection()
        preventReentry
    {
        this.unprotectedTarget();
        this.protectedTarget();
    }
}