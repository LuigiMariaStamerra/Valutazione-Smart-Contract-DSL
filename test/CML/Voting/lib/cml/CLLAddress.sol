/*
Circular Linked List
based on https://github.com/o0ragman0o/LibCLL/blob/master/LibCLL.sol
This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.
*/

pragma solidity >=0.4.22 <0.7.0;

library CLLAddress {

    address constant NULL = address(0);
    address constant HEAD = address(0);
    bool constant PREV = false;
    bool constant NEXT = true;
    
    struct CLL {
        mapping (address => mapping (bool => address)) cll;
    }

    // n: node id  d: direction  r: return node id

    // Return existential state of a list.
    function exists(CLL storage self)
        internal view returns (bool)
    {
        if (self.cll[HEAD][PREV] != HEAD || self.cll[HEAD][NEXT] != HEAD)
            return true;
    }
    
    function nodeExists(CLL storage self, address n) 
        internal view returns (bool)
    {
        if (self.cll[n][PREV] == HEAD && self.cll[n][NEXT] == HEAD) {
            if (self.cll[HEAD][NEXT] == n) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
    
    function nodeAt(CLL storage self, uint index) 
        internal view returns (address) {
        require(index < sizeOf(self), "Invalid index value.");
        
        address i = step(self, HEAD, PREV);
        uint j = 0;
        
        while(j++ != index) {
            i = step(self, i, PREV);
        }
        return i;
    }
    
    function keys(CLL storage self) 
        internal view returns (address[] memory)
    {
        uint r = sizeOf(self);
        address[] memory arr = new address[](r);
        address i = step(self, HEAD, NEXT);
        while (i != HEAD) {
            i = step(self, i, NEXT);
            arr[--r] = getNodeLinks(self, i)[0];
        }
        return arr;
    }
    
    // Returns the number of elements in the list
    function sizeOf(CLL storage self)
        internal view returns (uint r)
    {
        address i = step(self, HEAD, NEXT);
        while (i != HEAD) {
            i = step(self, i, NEXT);
            r++;
        }
        return r;
    }

    // Returns the links of a node as and array
    function getNodeLinks(CLL storage self, address n)
        internal view returns (address[2] memory)
    {
        return [self.cll[n][PREV], self.cll[n][NEXT]];
    }

    // Returns the link of a node `n` in direction `d`.
    function step(CLL storage self, address n, bool d)
        internal view returns (address)
    {
        return self.cll[n][d];
    }

    // Can be used before `insert` to build an ordered list
    // `a` an existing node to search from, e.g. HEAD.
    // `b` value to seek
    // `r` first node beyond `b` in direction `d`
    function seek(CLL storage self, address a, address b, bool d)
        internal view returns (address r)
    {
        r = step(self, a, d);
        while  ((b!=r) && ((b < r) != d)) r = self.cll[r][d];
        return r;
    }

    // Creates a bidirectional link between two nodes on direction `d`
    function stitch(CLL storage self, address a, address b, bool d) internal {
        self.cll[b][!d] = a;
        self.cll[a][d] = b;
    }

    // Insert node `b` beside existing node `a` in direction `d`.
    function insert(CLL storage self, address a, address b, bool d) internal {
        require(b != NULL, "Illegal key value.");
        address c = self.cll[a][d];
        stitch (self, a, b, d);
        stitch (self, b, c, d);
    }
    
    // Remove node
    function remove(CLL storage self, address n) internal returns (address) {
        if (n == NULL) return n;
        stitch(self, self.cll[n][PREV], self.cll[n][NEXT], NEXT);
        delete self.cll[n][PREV];
        delete self.cll[n][NEXT];
        return n;
    }

    // Push a new node before or after the head
    function push(CLL storage self, address n, bool d) internal {
        insert(self, HEAD, n, d);
    }
    
    // Pop a new node from before or after the head
    function pop(CLL storage self, bool d) internal returns (address) {
        return remove(self, step(self, HEAD, d));
    }
}