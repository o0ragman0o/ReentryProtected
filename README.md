# Rentry Protected
`ReentryProtected` is a Solidity smart contract which can be used to prevent contract reentry.

Smart contracts on the Ethereum platform are allowed to call other contracts by design. However this presents an opportunity for the called contract to call back into the calling contract using a different memory context. This can result in the initial contract being run with two or more conflicting 'awarenesses' of the state variables it contains. Such a situation can easily lead to unpredictable and unrecoverable mutations to its state variables and is therefore seen as a **high security risk**.

Protection against reentry can be achieved using a trivial implementation of a *mutual exclusion* flag called a *mutex* and is defined here as `bool __reMutex`. Mutex setting and testing is afforded to the contract's functions by the use of *modifiers* in the function implementation.

Two such modifiers are provided,`preventReentry()` which tests, sets and releases the mutex, and `noReentry` which simply tests the mutex. In both cases the contract will `throw` if it finds the mutex `true`.

## preventReentry()
```
    modifier preventReentry() {
        require(!reMutex);
        else __reMutex = true;
        _;
        delete __reMutex;
        return;
    }
```

`preventReentry()` initiates protection and so is intended to be applied to a public contract which may result in the calling of an external contract.  It consumes gas for the storage operation, some of which is refunded when the function returns. Its usage places some constraints on the design of the function applying it. `preventReentry()` wraps the function. On entry, the mutex is tested and set if found to be false.  The function code is run to completion and the mutex is then released before returning any function return parameters. The design constraints are therefore;
>1. The function itself cannot use `return` or have multiple points of exit.
>2. The function must use named return parameters.

```
function externalCall(address a) public preventReentry returns (bool success_) {
    success_ = a.transfer(1 ether);
}
```
## noReentry()

`noReentry` simply tests the mutex state and throws if found to be true. It can be applied to public functions that may change state variables but do not need to make external calls and so protects against multiple memory contexts acting upon the state variables. It is a simple entry test and no constraints are placed upon the design of the function itself. 

```
function set(uint a) public noReentry returns (bool) {
	safeStateVariable = a;
	return true;
}
```
## canEnter()
While not implemented in the `ReentryProtected` contract, a suggested practice for derived contracts is to have a `canEnter` modifier which may combine other  entry conditions, e.g.,
```
modifier canEnter() {
        require(!(__repMutex || foo == bar));
        _;
}
```
## Usage
```
pragma solidity ^0.4.10;
import "https://github.com/o0ragman0o/ReentryProtected/ReentryProtected.sol";

contract c is ReentryProtected {}
```
