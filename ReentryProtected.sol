/*
file:   ReentryProtection.sol
ver:    0.3.0
updated:6-April-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

Mutex based reentry protection protect.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.10;

contract ReentryProtected
{
    // The reentry protection state mutex.
    bool __reMutex;

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
        return;
    }

    // This modifier can be applied to public access state mutation functions
    // to protect against reentry if a `preventReentry` function has already
    // set the mutex. This prevents the contract from being reenter under a
    // different memory context which can break state variable integrity.
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
}
