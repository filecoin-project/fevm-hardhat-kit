
// File: @zondax/solidity-bignumber/src/BigNumbers.sol


pragma solidity 0.8.17;

// Definition here allows both the lib and inheriting contracts to use BigNumber directly.
struct BigNumber { 
    bytes val;
    bool neg;
    uint bitlen;
}

/**
 * @notice BigNumbers library for Solidity.
 */
library BigNumbers {
    
    /// @notice the value for number 0 of a BigNumber instance.
    bytes constant ZERO = hex"0000000000000000000000000000000000000000000000000000000000000000";
    /// @notice the value for number 1 of a BigNumber instance.
    bytes constant  ONE = hex"0000000000000000000000000000000000000000000000000000000000000001";
    /// @notice the value for number 2 of a BigNumber instance.
    bytes constant  TWO = hex"0000000000000000000000000000000000000000000000000000000000000002";

    // ***************** BEGIN EXPOSED MANAGEMENT FUNCTIONS ******************
    /** @notice verify a BN instance
     *  @dev checks if the BN is in the correct format. operations should only be carried out on
     *       verified BNs, so it is necessary to call this if your function takes an arbitrary BN
     *       as input.
     *
     *  @param bn BigNumber instance
     */
    function verify(
        BigNumber memory bn
    ) internal pure {
        uint msword; 
        bytes memory val = bn.val;
        assembly {msword := mload(add(val,0x20))} //get msword of result
        if(msword==0) require(isZero(bn));
        else require((bn.val.length % 32 == 0) && (msword>>((bn.bitlen%256)-1)==1));
    }

    /** @notice initialize a BN instance
     *  @dev wrapper function for _init. initializes from bytes value.
     *       Allows passing bitLength of value. This is NOT verified in the internal function. Only use where bitlen is
     *       explicitly known; otherwise use the other init function.
     *
     *  @param val BN value. may be of any size.
     *  @param neg neg whether the BN is +/-
     *  @param bitlen bit length of output.
     *  @return BigNumber instance
     */
    function init(
        bytes memory val, 
        bool neg, 
        uint bitlen
    ) internal view returns(BigNumber memory){
        return _init(val, neg, bitlen);
    }
    
    /** @notice initialize a BN instance
     *  @dev wrapper function for _init. initializes from bytes value.
     *
     *  @param val BN value. may be of any size.
     *  @param neg neg whether the BN is +/-
     *  @return BigNumber instance
     */
    function init(
        bytes memory val, 
        bool neg
    ) internal view returns(BigNumber memory){
        return _init(val, neg, 0);
    }

    /** @notice initialize a BN instance
     *  @dev wrapper function for _init. initializes from uint value (converts to bytes); 
     *       tf. resulting BN is in the range -2^256-1 ... 2^256-1.
     *
     *  @param val uint value.
     *  @param neg neg whether the BN is +/-
     *  @return BigNumber instance
     */
    function init(
        uint val, 
        bool neg
    ) internal view returns(BigNumber memory){
        return _init(abi.encodePacked(val), neg, 0);
    }
    // ***************** END EXPOSED MANAGEMENT FUNCTIONS ******************




    // ***************** BEGIN EXPOSED CORE CALCULATION FUNCTIONS ******************
    /** @notice BigNumber addition: a + b.
      * @dev add: Initially prepare BigNumbers for addition operation; internally calls actual addition/subtraction,
      *           depending on inputs.
      *           In order to do correct addition or subtraction we have to handle the sign.
      *           This function discovers the sign of the result based on the inputs, and calls the correct operation.
      *
      * @param a first BN
      * @param b second BN
      * @return r result  - addition of a and b.
      */
    function add(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(BigNumber memory r) {
        if(a.bitlen==0 && b.bitlen==0) return zero();
        if(a.bitlen==0) return b;
        if(b.bitlen==0) return a;
        bytes memory val;
        uint bitlen;
        int compare = cmp(a,b,false);

        if(a.neg || b.neg){
            if(a.neg && b.neg){
                if(compare>=0) (val, bitlen) = _add(a.val,b.val,a.bitlen);
                else (val, bitlen) = _add(b.val,a.val,b.bitlen);
                r.neg = true;
            }
            else {
                if(compare==1){
                    (val, bitlen) = _sub(a.val,b.val);
                    r.neg = a.neg;
                }
                else if(compare==-1){
                    (val, bitlen) = _sub(b.val,a.val);
                    r.neg = !a.neg;
                }
                else return zero();//one pos and one neg, and same value.
            }
        }
        else{
            if(compare>=0){ // a>=b
                (val, bitlen) = _add(a.val,b.val,a.bitlen);
            }
            else {
                (val, bitlen) = _add(b.val,a.val,b.bitlen);
            }
            r.neg = false;
        }

        r.val = val;
        r.bitlen = (bitlen);
    }

    /** @notice BigNumber subtraction: a - b.
      * @dev sub: Initially prepare BigNumbers for subtraction operation; internally calls actual addition/subtraction,
                  depending on inputs.
      *           In order to do correct addition or subtraction we have to handle the sign.
      *           This function discovers the sign of the result based on the inputs, and calls the correct operation.
      *
      * @param a first BN
      * @param b second BN
      * @return r result - subtraction of a and b.
      */  
    function sub(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(BigNumber memory r) {
        if(a.bitlen==0 && b.bitlen==0) return zero();
        bytes memory val;
        int compare;
        uint bitlen;
        compare = cmp(a,b,false);
        if(a.neg || b.neg) {
            if(a.neg && b.neg){           
                if(compare == 1) { 
                    (val,bitlen) = _sub(a.val,b.val); 
                    r.neg = true;
                }
                else if(compare == -1) { 

                    (val,bitlen) = _sub(b.val,a.val); 
                    r.neg = false;
                }
                else return zero();
            }
            else {
                if(compare >= 0) (val,bitlen) = _add(a.val,b.val,a.bitlen);
                else (val,bitlen) = _add(b.val,a.val,b.bitlen);
                
                r.neg = (a.neg) ? true : false;
            }
        }
        else {
            if(compare == 1) {
                (val,bitlen) = _sub(a.val,b.val);
                r.neg = false;
             }
            else if(compare == -1) { 
                (val,bitlen) = _sub(b.val,a.val);
                r.neg = true;
            }
            else return zero(); 
        }
        
        r.val = val;
        r.bitlen = (bitlen);
    }

    /** @notice BigNumber multiplication: a * b.
      * @dev mul: takes two BigNumbers and multiplys them. Order is irrelevant.
      *              multiplication achieved using modexp precompile:
      *                 (a * b) = ((a + b)**2 - (a - b)**2) / 4
      *
      * @param a first BN
      * @param b second BN
      * @return r result - multiplication of a and b.
      */
    function mul(
        BigNumber memory a, 
        BigNumber memory b
    ) internal view returns(BigNumber memory r){
            
        BigNumber memory lhs = add(a,b);
        BigNumber memory fst = modexp(lhs, two(), _powModulus(lhs, 2)); // (a+b)^2
        
        // no need to do subtraction part of the equation if a == b; if so, it has no effect on final result.
        if(!eq(a,b)) {
            BigNumber memory rhs = sub(a,b);
            BigNumber memory snd = modexp(rhs, two(), _powModulus(rhs, 2)); // (a-b)^2
            r = _shr(sub(fst, snd) , 2); // (a * b) = (((a + b)**2 - (a - b)**2) / 4
        }
        else {
            r = _shr(fst, 2); // a==b ? (((a + b)**2 / 4
        }
    }

    /** @notice BigNumber division verification: a * b.
      * @dev div: takes three BigNumbers (a,b and result), and verifies that a/b == result.
      * Performing BigNumber division on-chain is a significantly expensive operation. As a result, 
      * we expose the ability to verify the result of a division operation, which is a constant time operation. 
      *              (a/b = result) == (a = b * result)
      *              Integer division only; therefore:
      *                verify ((b*result) + (a % (b*result))) == a.
      *              eg. 17/7 == 2:
      *                verify  (7*2) + (17 % (7*2)) == 17.
      * The function returns a bool on successful verification. The require statements will ensure that false can never
      *  be returned, however inheriting contracts may also want to put this function inside a require statement.
      *  
      * @param a first BigNumber
      * @param b second BigNumber
      * @param r result BigNumber
      * @return bool whether or not the operation was verified
      */
    function divVerify(
        BigNumber memory a, 
        BigNumber memory b, 
        BigNumber memory r
    ) internal view returns(bool) {

        // first do zero check.
        // if a<b (always zero) and r==zero (input check), return true.
        if(cmp(a, b, false) == -1){
            require(cmp(zero(), r, false)==0);
            return true;
        }

        // Following zero check:
        //if both negative: result positive
        //if one negative: result negative
        //if neither negative: result positive
        bool positiveResult = ( a.neg && b.neg ) || (!a.neg && !b.neg);
        require(positiveResult ? !r.neg : r.neg);
        
        // require denominator to not be zero.
        require(!(cmp(b,zero(),true)==0));
        
        // division result check assumes inputs are positive.
        // we have already checked for result sign so this is safe.
        bool[3] memory negs = [a.neg, b.neg, r.neg];
        a.neg = false;
        b.neg = false;
        r.neg = false;

        // do multiplication (b * r)
        BigNumber memory fst = mul(b,r);
        // check if we already have 'a' (ie. no remainder after division). if so, no mod necessary, and return true.
        if(cmp(fst,a,true)==0) return true;
        //a mod (b*r)
        BigNumber memory snd = modexp(a,one(),fst); 
        // ((b*r) + a % (b*r)) == a
        require(cmp(add(fst,snd),a,true)==0); 

        a.neg = negs[0];
        b.neg = negs[1];
        r.neg = negs[2];

        return true;
    }

    /** @notice BigNumber exponentiation: a ^ b.
      * @dev pow: takes a BigNumber and a uint (a,e), and calculates a^e.
      * modexp precompile is used to achieve a^e; for this is work, we need to work out the minimum modulus value 
      * such that the modulus passed to modexp is not used. the result of a^e can never be more than size bitlen(a) * e.
      * 
      * @param a BigNumber
      * @param e exponent
      * @return r result BigNumber
      */
    function pow(
        BigNumber memory a, 
        uint e
    ) internal view returns(BigNumber memory){
        return modexp(a, init(e, false), _powModulus(a, e));
    }

    /** @notice BigNumber modulus: a % n.
      * @dev mod: takes a BigNumber and modulus BigNumber (a,n), and calculates a % n.
      * modexp precompile is used to achieve a % n; an exponent of value '1' is passed.
      * @param a BigNumber
      * @param n modulus BigNumber
      * @return r result BigNumber
      */
    function mod(
        BigNumber memory a, 
        BigNumber memory n
    ) internal view returns(BigNumber memory){
      return modexp(a,one(),n);
    }

    /** @notice BigNumber modular exponentiation: a^e mod n.
      * @dev modexp: takes base, exponent, and modulus, internally computes base^exponent % modulus using the precompile at address 0x5, and creates new BigNumber.
      *              this function is overloaded: it assumes the exponent is positive. if not, the other method is used, whereby the inverse of the base is also passed.
      *
      * @param a base BigNumber
      * @param e exponent BigNumber
      * @param n modulus BigNumber
      * @return result BigNumber
      */    
    function modexp(
        BigNumber memory a, 
        BigNumber memory e, 
        BigNumber memory n
    ) internal view returns(BigNumber memory) {
        //if exponent is negative, other method with this same name should be used.
        //if modulus is negative or zero, we cannot perform the operation.
        require(  e.neg==false
                && n.neg==false
                && !isZero(n.val));

        bytes memory _result = _modexp(a.val,e.val,n.val);
        //get bitlen of result (TODO: optimise. we know bitlen is in the same byte as the modulus bitlen byte)
        uint bitlen = bitLength(_result);
        
        // if result is 0, immediately return.
        if(bitlen == 0) return zero();
        // if base is negative AND exponent is odd, base^exp is negative, and tf. result is negative;
        // in that case we make the result positive by adding the modulus.
        if(a.neg && isOdd(e)) return add(BigNumber(_result, true, bitlen), n);
        // in any other case we return the positive result.
        return BigNumber(_result, false, bitlen);
    }

    /** @notice BigNumber modular exponentiation with negative base: inv(a)==a_inv && a_inv^e mod n.
    /** @dev modexp: takes base, base inverse, exponent, and modulus, asserts inverse(base)==base inverse, 
      *              internally computes base_inverse^exponent % modulus and creates new BigNumber.
      *              this function is overloaded: it assumes the exponent is negative. 
      *              if not, the other method is used, where the inverse of the base is not passed.
      *
      * @param a base BigNumber
      * @param ai base inverse BigNumber
      * @param e exponent BigNumber
      * @param a modulus
      * @return BigNumber memory result.
      */ 
    function modexp(
        BigNumber memory a, 
        BigNumber memory ai, 
        BigNumber memory e, 
        BigNumber memory n) 
    internal view returns(BigNumber memory) {
        // base^-exp = (base^-1)^exp
        require(!a.neg && e.neg);

        //if modulus is negative or zero, we cannot perform the operation.
        require(!n.neg && !isZero(n.val));

        //base_inverse == inverse(base, modulus)
        require(modinvVerify(a, n, ai)); 
            
        bytes memory _result = _modexp(ai.val,e.val,n.val);
        //get bitlen of result (TODO: optimise. we know bitlen is in the same byte as the modulus bitlen byte)
        uint bitlen = bitLength(_result);

        // if result is 0, immediately return.
        if(bitlen == 0) return zero();
        // if base_inverse is negative AND exponent is odd, base_inverse^exp is negative, and tf. result is negative;
        // in that case we make the result positive by adding the modulus.
        if(ai.neg && isOdd(e)) return add(BigNumber(_result, true, bitlen), n);
        // in any other case we return the positive result.
        return BigNumber(_result, false, bitlen);
    }
 
    /** @notice modular multiplication: (a*b) % n.
      * @dev modmul: Takes BigNumbers for a, b, and modulus, and computes (a*b) % modulus
      *              We call mul for the two input values, before calling modexp, passing exponent as 1.
      *              Sign is taken care of in sub-functions.
      *
      * @param a BigNumber
      * @param b BigNumber
      * @param n Modulus BigNumber
      * @return result BigNumber
      */
    function modmul(
        BigNumber memory a, 
        BigNumber memory b, 
        BigNumber memory n) internal view returns(BigNumber memory) {       
        return mod(mul(a,b), n);       
    }

    /** @notice modular inverse verification: Verifies that (a*r) % n == 1.
      * @dev modinvVerify: Takes BigNumbers for base, modulus, and result, verifies (base*result)%modulus==1, and returns result.
      *              Similar to division, it's far cheaper to verify an inverse operation on-chain than it is to calculate it, so we allow the user to pass their own result.
      *
      * @param a base BigNumber
      * @param n modulus BigNumber
      * @param r result BigNumber
      * @return boolean result
      */
    function modinvVerify(
        BigNumber memory a, 
        BigNumber memory n, 
        BigNumber memory r
    ) internal view returns(bool) {
        require(!a.neg && !n.neg); //assert positivity of inputs.
        /*
         * the following proves:
         * - user result passed is correct for values base and modulus
         * - modular inverse exists for values base and modulus.
         * otherwise it fails.
         */        
        require(cmp(modmul(a, r, n),one(),true)==0);
        
        return true;
    }
    // ***************** END EXPOSED CORE CALCULATION FUNCTIONS ******************




    // ***************** START EXPOSED HELPER FUNCTIONS ******************
    /** @notice BigNumber odd number check
      * @dev isOdd: returns 1 if BigNumber value is an odd number and 0 otherwise.
      *              
      * @param a BigNumber
      * @return r Boolean result
      */  
    function isOdd(
        BigNumber memory a
    ) internal pure returns(bool r){
        assembly{
            let a_ptr := add(mload(a), mload(mload(a))) // go to least significant word
            r := mod(mload(a_ptr),2)                      // mod it with 2 (returns 0 or 1) 
        }
    }

    /** @notice BigNumber comparison
      * @dev cmp: Compares BigNumbers a and b. 'signed' parameter indiciates whether to consider the sign of the inputs.
      *           'trigger' is used to decide this - 
      *              if both negative, invert the result; 
      *              if both positive (or signed==false), trigger has no effect;
      *              if differing signs, we return immediately based on input.
      *           returns -1 on a<b, 0 on a==b, 1 on a>b.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @param signed whether to consider sign of inputs
      * @return int result
      */
    function cmp(
        BigNumber memory a, 
        BigNumber memory b, 
        bool signed
    ) internal pure returns(int){
        int trigger = 1;
        if(signed){
            if(a.neg && b.neg) trigger = -1;
            else if(a.neg==false && b.neg==true) return 1;
            else if(a.neg==true && b.neg==false) return -1;
        }

        if(a.bitlen>b.bitlen) return    trigger;   // 1*trigger
        if(b.bitlen>a.bitlen) return -1*trigger;

        uint a_ptr;
        uint b_ptr;
        uint a_word;
        uint b_word;

        uint len = a.val.length; //bitlen is same so no need to check length.

        assembly{
            a_ptr := add(mload(a),0x20) 
            b_ptr := add(mload(b),0x20)
        }

        for(uint i=0; i<len;i+=32){
            assembly{
                a_word := mload(add(a_ptr,i))
                b_word := mload(add(b_ptr,i))
            }

            if(a_word>b_word) return    trigger; // 1*trigger
            if(b_word>a_word) return -1*trigger; 

        }

        return 0; //same value.
    }

    /** @notice BigNumber equality
      * @dev eq: returns true if a==b. sign always considered.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @return boolean result
      */
    function eq(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(bool){
        int result = cmp(a, b, true);
        return (result==0) ? true : false;
    }

    /** @notice BigNumber greater than
      * @dev eq: returns true if a>b. sign always considered.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @return boolean result
      */
    function gt(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(bool){
        int result = cmp(a, b, true);
        return (result==1) ? true : false;
    }

    /** @notice BigNumber greater than or equal to
      * @dev eq: returns true if a>=b. sign always considered.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @return boolean result
      */
    function gte(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(bool){
        int result = cmp(a, b, true);
        return (result==1 || result==0) ? true : false;
    }

    /** @notice BigNumber less than
      * @dev eq: returns true if a<b. sign always considered.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @return boolean result
      */
    function lt(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(bool){
        int result = cmp(a, b, true);
        return (result==-1) ? true : false;
    }

    /** @notice BigNumber less than or equal o
      * @dev eq: returns true if a<=b. sign always considered.
      *           
      * @param a BigNumber
      * @param b BigNumber
      * @return boolean result
      */
    function lte(
        BigNumber memory a, 
        BigNumber memory b
    ) internal pure returns(bool){
        int result = cmp(a, b, true);
        return (result==-1 || result==0) ? true : false;
    }

    /** @notice right shift BigNumber value
      * @dev shr: right shift BigNumber a by 'bits' bits.
             copies input value to new memory location before shift and calls _shr function after. 
      * @param a BigNumber value to shift
      * @param bits amount of bits to shift by
      * @return result BigNumber
      */
    function shr(
        BigNumber memory a, 
        uint bits
    ) internal view returns(BigNumber memory){
        require(!a.neg);
        return _shr(a, bits);
    }

    /** @notice right shift BigNumber memory 'dividend' by 'bits' bits.
      * @dev _shr: Shifts input value in-place, ie. does not create new memory. shr function does this.
      * right shift does not necessarily have to copy into a new memory location. where the user wishes the modify
      * the existing value they have in place, they can use this.  
      * @param bn value to shift
      * @param bits amount of bits to shift by
      * @return r result
      */
    function _shr(BigNumber memory bn, uint bits) internal view returns(BigNumber memory){
        uint length;
        assembly { length := mload(mload(bn)) }

        // if bits is >= the bitlength of the value the result is always 0
        if(bits >= bn.bitlen) return BigNumber(ZERO,false,0); 
        
        // set bitlen initially as we will be potentially modifying 'bits'
        bn.bitlen = bn.bitlen-(bits);

        // handle shifts greater than 256:
        // if bits is greater than 256 we can simply remove any trailing words, by altering the BN length. 
        // we also update 'bits' so that it is now in the range 0..256.
        assembly {
            if or(gt(bits, 0x100), eq(bits, 0x100)) {
                length := sub(length, mul(div(bits, 0x100), 0x20))
                mstore(mload(bn), length)
                bits := mod(bits, 0x100)
            }

            // if bits is multiple of 8 (byte size), we can simply use identity precompile for cheap memcopy.
            // otherwise we shift each word, starting at the least signifcant word, one-by-one using the mask technique.
            // TODO it is possible to do this without the last two operations, see SHL identity copy.
            let bn_val_ptr := mload(bn)
            switch eq(mod(bits, 8), 0)
              case 1 {  
                  let bytes_shift := div(bits, 8)
                  let in          := mload(bn)
                  let inlength    := mload(in)
                  let insize      := add(inlength, 0x20)
                  let out         := add(in,     bytes_shift)
                  let outsize     := sub(insize, bytes_shift)
                  let success     := staticcall(450, 0x4, in, insize, out, insize)
                  mstore8(add(out, 0x1f), 0) // maintain our BN layout following identity call:
                  mstore(in, inlength)         // set current length byte to 0, and reset old length.
              }
              default {
                  let mask
                  let lsw
                  let mask_shift := sub(0x100, bits)
                  let lsw_ptr := add(bn_val_ptr, length)   
                  for { let i := length } eq(eq(i,0),0) { i := sub(i, 0x20) } { // for(int i=max_length; i!=0; i-=32)
                      switch eq(i,0x20)                                         // if i==32:
                          case 1 { mask := 0 }                                  //    - handles lsword: no mask needed.
                          default { mask := mload(sub(lsw_ptr,0x20)) }          //    - else get mask (previous word)
                      lsw := shr(bits, mload(lsw_ptr))                          // right shift current by bits
                      mask := shl(mask_shift, mask)                             // left shift next significant word by mask_shift
                      mstore(lsw_ptr, or(lsw,mask))                             // store OR'd mask and shifted bits in-place
                      lsw_ptr := sub(lsw_ptr, 0x20)                             // point to next bits.
                  }
              }

            // The following removes the leading word containing all zeroes in the result should it exist, 
            // as well as updating lengths and pointers as necessary.
            let msw_ptr := add(bn_val_ptr,0x20)
            switch eq(mload(msw_ptr), 0) 
                case 1 {
                   mstore(msw_ptr, sub(mload(bn_val_ptr), 0x20)) // store new length in new position
                   mstore(bn, msw_ptr)                           // update pointer from bn
                }
                default {}
        }
    

        return bn;
    }

    /** @notice left shift BigNumber value
      * @dev shr: left shift BigNumber a by 'bits' bits.
                  ensures the value is not negative before calling the private function.
      * @param a BigNumber value to shift
      * @param bits amount of bits to shift by
      * @return result BigNumber
      */
    function shl(
        BigNumber memory a, 
        uint bits
    ) internal view returns(BigNumber memory){
        require(!a.neg);
        return _shl(a, bits);
    }

    /** @notice sha3 hash a BigNumber.
      * @dev hash: takes a BigNumber and performs sha3 hash on it.
      *            we hash each BigNumber WITHOUT it's first word - first word is a pointer to the start of the bytes value,
      *            and so is different for each struct.
      *             
      * @param a BigNumber
      * @return h bytes32 hash.
      */
    function hash(
        BigNumber memory a
    ) internal pure returns(bytes32 h) {
        //amount of words to hash = all words of the value and three extra words: neg, bitlen & value length.     
        assembly {
            h := keccak256( add(a,0x20), add (mload(mload(a)), 0x60 ) ) 
        }
    }

    /** @notice BigNumber full zero check
      * @dev isZero: checks if the BigNumber is in the default zero format for BNs (ie. the result from zero()).
      *             
      * @param a BigNumber
      * @return boolean result.
      */
    function isZero(
        BigNumber memory a
    ) internal pure returns(bool) {
        return isZero(a.val) && a.val.length==0x20 && !a.neg && a.bitlen == 0;
    }


    /** @notice bytes zero check
      * @dev isZero: checks if input bytes value resolves to zero.
      *             
      * @param a bytes value
      * @return boolean result.
      */
    function isZero(
        bytes memory a
    ) internal pure returns(bool) {
        uint msword;
        uint msword_ptr;
        assembly {
            msword_ptr := add(a,0x20)
        }
        for(uint i=0; i<a.length; i+=32) {
            assembly { msword := mload(msword_ptr) } // get msword of input
            if(msword > 0) return false;
            assembly { msword_ptr := add(msword_ptr, 0x20) }
        }
        return true;

    }

    /** @notice BigNumber value bit length
      * @dev bitLength: returns BigNumber value bit length- ie. log2 (most significant bit of value)
      *             
      * @param a BigNumber
      * @return uint bit length result.
      */
    function bitLength(
        BigNumber memory a
    ) internal pure returns(uint){
        return bitLength(a.val);
    }

    /** @notice bytes bit length
      * @dev bitLength: returns bytes bit length- ie. log2 (most significant bit of value)
      *             
      * @param a bytes value
      * @return r uint bit length result.
      */
    function bitLength(
        bytes memory a
    ) internal pure returns(uint r){
        if(isZero(a)) return 0;
        uint msword; 
        assembly {
            msword := mload(add(a,0x20))               // get msword of input
        }
        r = bitLength(msword);                         // get bitlen of msword, add to size of remaining words.
        assembly {                                           
            r := add(r, mul(sub(mload(a), 0x20) , 8))  // res += (val.length-32)*8;  
        }
    }

    /** @notice uint bit length
        @dev bitLength: get the bit length of a uint input - ie. log2 (most significant bit of 256 bit value (one EVM word))
      *                       credit: Tjaden Hess @ ethereum.stackexchange             
      * @param a uint value
      * @return r uint bit length result.
      */
    function bitLength(
        uint a
    ) internal pure returns (uint r){
        assembly {
            switch eq(a, 0)
            case 1 {
                r := 0
            }
            default {
                let arg := a
                a := sub(a,1)
                a := or(a, div(a, 0x02))
                a := or(a, div(a, 0x04))
                a := or(a, div(a, 0x10))
                a := or(a, div(a, 0x100))
                a := or(a, div(a, 0x10000))
                a := or(a, div(a, 0x100000000))
                a := or(a, div(a, 0x10000000000000000))
                a := or(a, div(a, 0x100000000000000000000000000000000))
                a := add(a, 1)
                let m := mload(0x40)
                mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
                mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
                mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
                mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
                mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
                mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
                mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
                mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
                mstore(0x40, add(m, 0x100))
                let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
                let shift := 0x100000000000000000000000000000000000000000000000000000000000000
                let _a := div(mul(a, magic), shift)
                r := div(mload(add(m,sub(255,_a))), shift)
                r := add(r, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
                // where a is a power of two, result needs to be incremented. we use the power of two trick here: if(arg & arg-1 == 0) ++r;
                if eq(and(arg, sub(arg, 1)), 0) {
                    r := add(r, 1) 
                }
            }
        }
    }

    /** @notice BigNumber zero value
        @dev zero: returns zero encoded as a BigNumber
      * @return zero encoded as BigNumber
      */
    function zero(
    ) internal pure returns(BigNumber memory) {
        return BigNumber(ZERO, false, 0);
    }

    /** @notice BigNumber one value
        @dev one: returns one encoded as a BigNumber
      * @return one encoded as BigNumber
      */
    function one(
    ) internal pure returns(BigNumber memory) {
        return BigNumber(ONE, false, 1);
    }

    /** @notice BigNumber two value
        @dev two: returns two encoded as a BigNumber
      * @return two encoded as BigNumber
      */
    function two(
    ) internal pure returns(BigNumber memory) {
        return BigNumber(TWO, false, 2);
    }
    // ***************** END EXPOSED HELPER FUNCTIONS ******************





    // ***************** START PRIVATE MANAGEMENT FUNCTIONS ******************
    /** @notice Create a new BigNumber.
        @dev init: overloading allows caller to obtionally pass bitlen where it is known - as it is cheaper to do off-chain and verify on-chain. 
      *            we assert input is in data structure as defined above, and that bitlen, if passed, is correct.
      *            'copy' parameter indicates whether or not to copy the contents of val to a new location in memory (for example where you pass 
      *            the contents of another variable's value in)
      * @param val bytes - bignum value.
      * @param neg bool - sign of value
      * @param bitlen uint - bit length of value
      * @return r BigNumber initialized value.
      */
    function _init(
        bytes memory val, 
        bool neg, 
        uint bitlen
    ) private view returns(BigNumber memory r){ 
        // use identity at location 0x4 for cheap memcpy.
        // grab contents of val, load starting from memory end, update memory end pointer.
        assembly {
            let data := add(val, 0x20)
            let length := mload(val)
            let out
            let freemem := msize()
            switch eq(mod(length, 0x20), 0)                       // if(val.length % 32 == 0)
                case 1 {
                    out     := add(freemem, 0x20)                 // freememory location + length word
                    mstore(freemem, length)                       // set new length 
                }
                default { 
                    let offset  := sub(0x20, mod(length, 0x20))   // offset: 32 - (length % 32)
                    out     := add(add(freemem, offset), 0x20)    // freememory location + offset + length word
                    mstore(freemem, add(length, offset))          // set new length 
                }
            pop(staticcall(450, 0x4, data, length, out, length))  // copy into 'out' memory location
            mstore(0x40, add(freemem, add(mload(freemem), 0x20))) // update the free memory pointer
            
            // handle leading zero words. assume freemem is pointer to bytes value
            let bn_length := mload(freemem)
            for { } eq ( eq(bn_length, 0x20), 0) { } {            // for(; length!=32; length-=32)
             switch eq(mload(add(freemem, 0x20)),0)               // if(msword==0):
                    case 1 { freemem := add(freemem, 0x20) }      //     update length pointer
                    default { break }                             // else: loop termination. non-zero word found
                bn_length := sub(bn_length,0x20)                          
            } 
            mstore(freemem, bn_length)                             

            mstore(r, freemem)                                    // store new bytes value in r
            mstore(add(r, 0x20), neg)                             // store neg value in r
        }

        r.bitlen = bitlen == 0 ? bitLength(r.val) : bitlen;
    }
    // ***************** END PRIVATE MANAGEMENT FUNCTIONS ******************





    // ***************** START PRIVATE CORE CALCULATION FUNCTIONS ******************
    /** @notice takes two BigNumber memory values and the bitlen of the max value, and adds them.
      * @dev _add: This function is private and only callable from add: therefore the values may be of different sizes,
      *            in any order of size, and of different signs (handled in add).
      *            As values may be of different sizes, inputs are considered starting from the least significant 
      *            words, working back. 
      *            The function calculates the new bitlen (basically if bitlens are the same for max and min, 
      *            max_bitlen++) and returns a new BigNumber memory value.
      *
      * @param max bytes -  biggest value  (determined from add)
      * @param min bytes -  smallest value (determined from add)
      * @param max_bitlen uint - bit length of max value.
      * @return bytes result - max + min.
      * @return uint - bit length of result.
      */
    function _add(
        bytes memory max, 
        bytes memory min, 
        uint max_bitlen
    ) private pure returns (bytes memory, uint) {
        bytes memory result;
        assembly {

            let result_start := msize()                                       // Get the highest available block of memory
            let carry := 0
            let uint_max := sub(0,1)

            let max_ptr := add(max, mload(max))
            let min_ptr := add(min, mload(min))                               // point to last word of each byte array.

            let result_ptr := add(add(result_start,0x20), mload(max))         // set result_ptr end.

            for { let i := mload(max) } eq(eq(i,0),0) { i := sub(i, 0x20) } { // for(int i=max_length; i!=0; i-=32)
                let max_val := mload(max_ptr)                                 // get next word for 'max'
                switch gt(i,sub(mload(max),mload(min)))                       // if(i>(max_length-min_length)). while 
                                                                              // 'min' words are still available.
                    case 1{ 
                        let min_val := mload(min_ptr)                         //      get next word for 'min'
                        mstore(result_ptr, add(add(max_val,min_val),carry))   //      result_word = max_word+min_word+carry
                        switch gt(max_val, sub(uint_max,sub(min_val,carry)))  //      this switch block finds whether or
                                                                              //      not to set the carry bit for the
                                                                              //      next iteration.
                            case 1  { carry := 1 }
                            default {
                                switch and(eq(max_val,uint_max),or(gt(carry,0), gt(min_val,0)))
                                case 1 { carry := 1 }
                                default{ carry := 0 }
                            }
                            
                        min_ptr := sub(min_ptr,0x20)                       //       point to next 'min' word
                    }
                    default{                                               // else: remainder after 'min' words are complete.
                        mstore(result_ptr, add(max_val,carry))             //       result_word = max_word+carry
                        
                        switch and( eq(uint_max,max_val), eq(carry,1) )    //       this switch block finds whether or 
                                                                           //       not to set the carry bit for the 
                                                                           //       next iteration.
                            case 1  { carry := 1 }
                            default { carry := 0 }
                    }
                result_ptr := sub(result_ptr,0x20)                         // point to next 'result' word
                max_ptr := sub(max_ptr,0x20)                               // point to next 'max' word
            }

            switch eq(carry,0) 
                case 1{ result_start := add(result_start,0x20) }           // if carry is 0, increment result_start, ie.
                                                                           // length word for result is now one word 
                                                                           // position ahead.
                default { mstore(result_ptr, 1) }                          // else if carry is 1, store 1; overflow has
                                                                           // occured, so length word remains in the 
                                                                           // same position.

            result := result_start                                         // point 'result' bytes value to the correct
                                                                           // address in memory.
            mstore(result,add(mload(max),mul(0x20,carry)))                 // store length of result. we are finished 
                                                                           // with the byte array.
            
            mstore(0x40, add(result,add(mload(result),0x20)))              // Update freemem pointer to point to new 
                                                                           // end of memory.

            // we now calculate the result's bit length.
            // with addition, if we assume that some a is at least equal to some b, then the resulting bit length will
            // be a's bit length or (a's bit length)+1, depending on carry bit.this is cheaper than calling bitLength.
            let msword := mload(add(result,0x20))                             // get most significant word of result
            // if(msword==1 || msword>>(max_bitlen % 256)==1):
            if or( eq(msword, 1), eq(shr(mod(max_bitlen,256),msword),1) ) {
                    max_bitlen := add(max_bitlen, 1)                          // if msword's bit length is 1 greater 
                                                                              // than max_bitlen, OR overflow occured,
                                                                              // new bitlen is max_bitlen+1.
                }
        }
        

        return (result, max_bitlen);
    }

    /** @notice takes two BigNumber memory values and subtracts them.
      * @dev _sub: This function is private and only callable from add: therefore the values may be of different sizes, 
      *            in any order of size, and of different signs (handled in add).
      *            As values may be of different sizes, inputs are considered starting from the least significant words,
      *            working back. 
      *            The function calculates the new bitlen (basically if bitlens are the same for max and min, 
      *            max_bitlen++) and returns a new BigNumber memory value.
      *
      * @param max bytes -  biggest value  (determined from add)
      * @param min bytes -  smallest value (determined from add)
      * @return bytes result - max + min.
      * @return uint - bit length of result.
      */
    function _sub(
        bytes memory max, 
        bytes memory min
    ) internal pure returns (bytes memory, uint) {
        bytes memory result;
        uint carry = 0;
        uint uint_max = type(uint256).max;
        assembly {
                
            let result_start := msize()                                     // Get the highest available block of 
                                                                            // memory
        
            let max_len := mload(max)
            let min_len := mload(min)                                       // load lengths of inputs
            
            let len_diff := sub(max_len,min_len)                            // get differences in lengths.
            
            let max_ptr := add(max, max_len)
            let min_ptr := add(min, min_len)                                // go to end of arrays
            let result_ptr := add(result_start, max_len)                    // point to least significant result 
                                                                            // word.
            let memory_end := add(result_ptr,0x20)                          // save memory_end to update free memory
                                                                            // pointer at the end.
            
            for { let i := max_len } eq(eq(i,0),0) { i := sub(i, 0x20) } {  // for(int i=max_length; i!=0; i-=32)
                let max_val := mload(max_ptr)                               // get next word for 'max'
                switch gt(i,len_diff)                                       // if(i>(max_length-min_length)). while
                                                                            // 'min' words are still available.
                    case 1{ 
                        let min_val := mload(min_ptr)                       //  get next word for 'min'
        
                        mstore(result_ptr, sub(sub(max_val,min_val),carry)) //  result_word = (max_word-min_word)-carry
                    
                        switch or(lt(max_val, add(min_val,carry)), 
                               and(eq(min_val,uint_max), eq(carry,1)))      //  this switch block finds whether or 
                                                                            //  not to set the carry bit for the next iteration.
                            case 1  { carry := 1 }
                            default { carry := 0 }
                            
                        min_ptr := sub(min_ptr,0x20)                        //  point to next 'result' word
                    }
                    default {                                               // else: remainder after 'min' words are complete.

                        mstore(result_ptr, sub(max_val,carry))              //      result_word = max_word-carry
                    
                        switch and( eq(max_val,0), eq(carry,1) )            //      this switch block finds whether or 
                                                                            //      not to set the carry bit for the 
                                                                            //      next iteration.
                            case 1  { carry := 1 }
                            default { carry := 0 }

                    }
                result_ptr := sub(result_ptr,0x20)                          // point to next 'result' word
                max_ptr    := sub(max_ptr,0x20)                             // point to next 'max' word
            }      

            //the following code removes any leading words containing all zeroes in the result.
            result_ptr := add(result_ptr,0x20)                                                 

            // for(result_ptr+=32;; result==0; result_ptr+=32)
            for { }   eq(mload(result_ptr), 0) { result_ptr := add(result_ptr,0x20) } { 
               result_start := add(result_start, 0x20)                      // push up the start pointer for the result
               max_len := sub(max_len,0x20)                                 // subtract a word (32 bytes) from the 
                                                                            // result length.
            } 

            result := result_start                                          // point 'result' bytes value to 
                                                                            // the correct address in memory
            
            mstore(result,max_len)                                          // store length of result. we 
                                                                            // are finished with the byte array.
            
            mstore(0x40, memory_end)                                        // Update freemem pointer.
        }

        uint new_bitlen = bitLength(result);                                // calculate the result's 
                                                                            // bit length.
        
        return (result, new_bitlen);
    }

    /** @notice gets the modulus value necessary for calculating exponetiation.
      * @dev _powModulus: we must pass the minimum modulus value which would return JUST the a^b part of the calculation
      *       in modexp. the rationale here is:
      *       if 'a' has n bits, then a^e has at most n*e bits.
      *       using this modulus in exponetiation will result in simply a^e.
      *       therefore the value may be many words long.
      *       This is done by:
      *         - storing total modulus byte length
      *         - storing first word of modulus with correct bit set
      *         - updating the free memory pointer to come after total length.
      *
      * @param a BigNumber base
      * @param e uint exponent
      * @return BigNumber modulus result
      */
    function _powModulus(
        BigNumber memory a, 
        uint e
    ) private pure returns(BigNumber memory){
        bytes memory _modulus = ZERO;
        uint mod_index;

        assembly {
            mod_index := mul(mload(add(a, 0x40)), e)               // a.bitlen * e is the max bitlength of result
            let first_word_modulus := shl(mod(mod_index, 256), 1)  // set bit in first modulus word.
            mstore(_modulus, mul(add(div(mod_index,256),1),0x20))  // store length of modulus
            mstore(add(_modulus,0x20), first_word_modulus)         // set first modulus word
            mstore(0x40, add(_modulus, add(mload(_modulus),0x20))) // update freemem pointer to be modulus index
                                                                   // + length
        }

        //create modulus BigNumber memory for modexp function
        return BigNumber(_modulus, false, mod_index); 
    }

    /** @notice Modular Exponentiation: Takes bytes values for base, exp, mod and calls precompile for (base^exp)%^mod
      * @dev modexp: Wrapper for built-in modexp (contract 0x5) as described here: 
      *              https://github.com/ethereum/EIPs/pull/198
      *
      * @param _b bytes base
      * @param _e bytes base_inverse 
      * @param _m bytes exponent
      * @param r bytes result.
      */
    function _modexp(
        bytes memory _b, 
        bytes memory _e, 
        bytes memory _m
    ) private view returns(bytes memory r) {
        assembly {
            
            let bl := mload(_b)
            let el := mload(_e)
            let ml := mload(_m)
            
            
            let freemem := mload(0x40) // Free memory pointer is always stored at 0x40
            
            
            mstore(freemem, bl)         // arg[0] = base.length @ +0
            
            mstore(add(freemem,32), el) // arg[1] = exp.length @ +32
            
            mstore(add(freemem,64), ml) // arg[2] = mod.length @ +64
            
            // arg[3] = base.bits @ + 96
            // Use identity built-in (contract 0x4) as a cheap memcpy
            let success := staticcall(450, 0x4, add(_b,32), bl, add(freemem,96), bl)
            
            // arg[4] = exp.bits @ +96+base.length
            let size := add(96, bl)
            success := staticcall(450, 0x4, add(_e,32), el, add(freemem,size), el)
            
            // arg[5] = mod.bits @ +96+base.length+exp.length
            size := add(size,el)
            success := staticcall(450, 0x4, add(_m,32), ml, add(freemem,size), ml)
            
            switch success case 0 { invalid() } //fail where we haven't enough gas to make the call

            // Total size of input = 96+base.length+exp.length+mod.length
            size := add(size,ml)
            // Invoke contract 0x5, put return value right after mod.length, @ +96
            success := staticcall(sub(gas(), 1350), 0x5, freemem, size, add(freemem, 0x60), ml)

            switch success case 0 { invalid() } //fail where we haven't enough gas to make the call

            let length := ml
            let msword_ptr := add(freemem, 0x60)

            ///the following code removes any leading words containing all zeroes in the result.
            for { } eq ( eq(length, 0x20), 0) { } {                   // for(; length!=32; length-=32)
                switch eq(mload(msword_ptr),0)                        // if(msword==0):
                    case 1 { msword_ptr := add(msword_ptr, 0x20) }    //     update length pointer
                    default { break }                                 // else: loop termination. non-zero word found
                length := sub(length,0x20)                          
            } 
            r := sub(msword_ptr,0x20)
            mstore(r, length)
            
            // point to the location of the return value (length, bits)
            //assuming mod length is multiple of 32, return value is already in the right format.
            mstore(0x40, add(add(96, freemem),ml)) //deallocate freemem pointer
        }        
    }
    // ***************** END PRIVATE CORE CALCULATION FUNCTIONS ******************





    // ***************** START PRIVATE HELPER FUNCTIONS ******************
    /** @notice left shift BigNumber memory 'dividend' by 'value' bits.
      * @param bn value to shift
      * @param bits amount of bits to shift by
      * @return r result
      */
    function _shl(
        BigNumber memory bn, 
        uint bits
    ) private view returns(BigNumber memory r) {
        if(bits==0 || bn.bitlen==0) return bn;
        
        // we start by creating an empty bytes array of the size of the output, based on 'bits'.
        // for that we must get the amount of extra words needed for the output.
        uint length = bn.val.length;
        // position of bitlen in most significnat word
        uint bit_position = ((bn.bitlen-1) % 256) + 1;
        // total extra words. we check if the bits remainder will add one more word.
        uint extra_words = (bits / 256) + ( (bits % 256) >= (256 - bit_position) ? 1 : 0);
        // length of output
        uint total_length = length + (extra_words * 0x20);

        r.bitlen = bn.bitlen+(bits);
        r.neg = bn.neg;
        bits %= 256;

        
        bytes memory bn_shift;
        uint bn_shift_ptr;
        // the following efficiently creates an empty byte array of size 'total_length'
        assembly {
            let freemem_ptr := mload(0x40)                // get pointer to free memory
            mstore(freemem_ptr, total_length)             // store bytes length
            let mem_end := add(freemem_ptr, total_length) // end of memory
            mstore(mem_end, 0)                            // store 0 at memory end
            bn_shift := freemem_ptr                       // set pointer to bytes
            bn_shift_ptr := add(bn_shift, 0x20)           // get bn_shift pointer
            mstore(0x40, add(mem_end, 0x20))              // update freemem pointer
        }

        // use identity for cheap copy if bits is multiple of 8.
        if(bits % 8 == 0) {
            // calculate the position of the first byte in the result.
            uint bytes_pos = ((256-(((bn.bitlen-1)+bits) % 256))-1) / 8;
            uint insize = (bn.bitlen / 8) + ((bn.bitlen % 8 != 0) ? 1 : 0);
            assembly {
              let in          := add(add(mload(bn), 0x20), div(sub(256, bit_position), 8))
              let out         := add(bn_shift_ptr, bytes_pos)
              let success     := staticcall(450, 0x4, in, insize, out, length)
            }
            r.val = bn_shift;
            return r;
        }


        uint mask;
        uint mask_shift = 0x100-bits;
        uint msw;
        uint msw_ptr;

       assembly {
           msw_ptr := add(mload(bn), 0x20)   
       }
        
       // handle first word before loop if the shift adds any extra words.
       // the loop would handle it if the bit shift doesn't wrap into the next word, 
       // so we check only for that condition.
       if((bit_position+bits) > 256){
           assembly {
              msw := mload(msw_ptr)
              mstore(bn_shift_ptr, shr(mask_shift, msw))
              bn_shift_ptr := add(bn_shift_ptr, 0x20)
           }
       }
        
       // as a result of creating the empty array we just have to operate on the words in the original bn.
       for(uint i=bn.val.length; i!=0; i-=0x20){                  // for each word:
           assembly {
               msw := mload(msw_ptr)                              // get most significant word
               switch eq(i,0x20)                                  // if i==32:
                   case 1 { mask := 0 }                           // handles msword: no mask needed.
                   default { mask := mload(add(msw_ptr,0x20)) }   // else get mask (next word)
               msw := shl(bits, msw)                              // left shift current msw by 'bits'
               mask := shr(mask_shift, mask)                      // right shift next significant word by mask_shift
               mstore(bn_shift_ptr, or(msw,mask))                 // store OR'd mask and shifted bits in-place
               msw_ptr := add(msw_ptr, 0x20)
               bn_shift_ptr := add(bn_shift_ptr, 0x20)
           }
       }

       r.val = bn_shift;
    }
    // ***************** END PRIVATE HELPER FUNCTIONS ******************
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/CborDecode.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;

// 	MajUnsignedInt = 0
// 	MajSignedInt   = 1
// 	MajByteString  = 2
// 	MajTextString  = 3
// 	MajArray       = 4
// 	MajMap         = 5
// 	MajTag         = 6
// 	MajOther       = 7

uint8 constant MajUnsignedInt = 0;
uint8 constant MajSignedInt = 1;
uint8 constant MajByteString = 2;
uint8 constant MajTextString = 3;
uint8 constant MajArray = 4;
uint8 constant MajMap = 5;
uint8 constant MajTag = 6;
uint8 constant MajOther = 7;

uint8 constant TagTypeBigNum = 2;
uint8 constant TagTypeNegativeBigNum = 3;

uint8 constant True_Type = 21;
uint8 constant False_Type = 20;

/// @notice This library is a set a functions that allows anyone to decode cbor encoded bytes
/// @dev methods in this library try to read the data type indicated from cbor encoded data stored in bytes at a specific index
/// @dev if it successes, methods will return the read value and the new index (intial index plus read bytes)
/// @author Zondax AG
library CBORDecoder {
    /// @notice check if next value on the cbor encoded data is null
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    function isNullNext(bytes memory cborData, uint byteIdx) internal pure returns (bool) {
        return cborData[byteIdx] == hex"f6";
    }

    /// @notice attempt to read a bool value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return a bool decoded from input bytes and the byte index after moving past the value
    function readBool(bytes memory cborData, uint byteIdx) internal pure returns (bool, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajOther, "invalid maj (expected MajOther)");
        assert(value == True_Type || value == False_Type);

        return (value != False_Type, byteIdx);
    }

    /// @notice attempt to read the length of a fixed array
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return length of the fixed array decoded from input bytes and the byte index after moving past the value
    function readFixedArray(bytes memory cborData, uint byteIdx) internal pure returns (uint, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajArray, "invalid maj (expected MajArray)");

        return (len, byteIdx);
    }

    /// @notice attempt to read an arbitrary length string value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return arbitrary length string decoded from input bytes and the byte index after moving past the value
    function readString(bytes memory cborData, uint byteIdx) internal pure returns (string memory, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajTextString, "invalid maj (expected MajTextString)");

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(len);
        uint slice_index = 0;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborData[i];
            slice_index++;
        }

        return (string(slice), byteIdx + len);
    }

    /// @notice attempt to read an arbitrary byte string value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return arbitrary byte string decoded from input bytes and the byte index after moving past the value
    function readBytes(bytes memory cborData, uint byteIdx) internal pure returns (bytes memory, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajTag || maj == MajByteString, "invalid maj (expected MajTag or MajByteString)");

        if (maj == MajTag) {
            (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
            assert(maj == MajByteString);
        }

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(len);
        uint slice_index = 0;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborData[i];
            slice_index++;
        }

        return (slice, byteIdx + len);
    }

    /// @notice attempt to read a bytes32 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return a bytes32 decoded from input bytes and the byte index after moving past the value
    function readBytes32(bytes memory cborData, uint byteIdx) internal pure returns (bytes32, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajByteString, "invalid maj (expected MajByteString)");

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(32);
        uint slice_index = 32 - len;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = cborData[i];
            slice_index++;
        }

        return (bytes32(slice), byteIdx + len);
    }

    /// @notice attempt to read a uint256 value encoded per cbor specification
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an uint256 decoded from input bytes and the byte index after moving past the value
    function readUInt256(bytes memory cborData, uint byteIdx) internal pure returns (uint256, uint) {
        uint8 maj;
        uint256 value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajTag || maj == MajUnsignedInt, "invalid maj (expected MajTag or MajUnsignedInt)");

        if (maj == MajTag) {
            require(value == TagTypeBigNum, "invalid tag (expected TagTypeBigNum)");

            uint len;
            (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
            require(maj == MajByteString, "invalid maj (expected MajByteString)");

            require(cborData.length >= byteIdx + len, "slicing out of range");
            assembly {
                value := mload(add(cborData, add(len, byteIdx)))
            }

            return (value, byteIdx + len);
        }

        return (value, byteIdx);
    }

    /// @notice attempt to read a int256 value encoded per cbor specification
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an int256 decoded from input bytes and the byte index after moving past the value
    function readInt256(bytes memory cborData, uint byteIdx) internal pure returns (int256, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajTag || maj == MajSignedInt, "invalid maj (expected MajTag or MajSignedInt)");

        if (maj == MajTag) {
            assert(value == TagTypeNegativeBigNum);

            uint len;
            (maj, len, byteIdx) = parseCborHeader(cborData, byteIdx);
            require(maj == MajByteString, "invalid maj (expected MajByteString)");

            require(cborData.length >= byteIdx + len, "slicing out of range");
            assembly {
                value := mload(add(cborData, add(len, byteIdx)))
            }

            return (int256(value), byteIdx + len);
        }

        return (int256(value), byteIdx);
    }

    /// @notice attempt to read a uint64 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an uint64 decoded from input bytes and the byte index after moving past the value
    function readUInt64(bytes memory cborData, uint byteIdx) internal pure returns (uint64, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajUnsignedInt, "invalid maj (expected MajUnsignedInt)");

        return (uint64(value), byteIdx);
    }

    /// @notice attempt to read a uint32 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an uint32 decoded from input bytes and the byte index after moving past the value
    function readUInt32(bytes memory cborData, uint byteIdx) internal pure returns (uint32, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajUnsignedInt, "invalid maj (expected MajUnsignedInt)");

        return (uint32(value), byteIdx);
    }

    /// @notice attempt to read a uint16 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an uint16 decoded from input bytes and the byte index after moving past the value
    function readUInt16(bytes memory cborData, uint byteIdx) internal pure returns (uint16, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajUnsignedInt, "invalid maj (expected MajUnsignedInt)");

        return (uint16(value), byteIdx);
    }

    /// @notice attempt to read a uint8 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an uint8 decoded from input bytes and the byte index after moving past the value
    function readUInt8(bytes memory cborData, uint byteIdx) internal pure returns (uint8, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajUnsignedInt, "invalid maj (expected MajUnsignedInt)");

        return (uint8(value), byteIdx);
    }

    /// @notice attempt to read a int64 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an int64 decoded from input bytes and the byte index after moving past the value
    function readInt64(bytes memory cborData, uint byteIdx) internal pure returns (int64, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajSignedInt || maj == MajUnsignedInt, "invalid maj (expected MajSignedInt or MajUnsignedInt)");

        return (int64(uint64(value)), byteIdx);
    }

    /// @notice attempt to read a int32 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an int32 decoded from input bytes and the byte index after moving past the value
    function readInt32(bytes memory cborData, uint byteIdx) internal pure returns (int32, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajSignedInt || maj == MajUnsignedInt, "invalid maj (expected MajSignedInt or MajUnsignedInt)");

        return (int32(uint32(value)), byteIdx);
    }

    /// @notice attempt to read a int16 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an int16 decoded from input bytes and the byte index after moving past the value
    function readInt16(bytes memory cborData, uint byteIdx) internal pure returns (int16, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajSignedInt || maj == MajUnsignedInt, "invalid maj (expected MajSignedInt or MajUnsignedInt)");

        return (int16(uint16(value)), byteIdx);
    }

    /// @notice attempt to read a int8 value
    /// @param cborData cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return an int8 decoded from input bytes and the byte index after moving past the value
    function readInt8(bytes memory cborData, uint byteIdx) internal pure returns (int8, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = parseCborHeader(cborData, byteIdx);
        require(maj == MajSignedInt || maj == MajUnsignedInt, "invalid maj (expected MajSignedInt or MajUnsignedInt)");

        return (int8(uint8(value)), byteIdx);
    }

    /// @notice slice uint8 from bytes starting at a given index
    /// @param bs bytes to slice from
    /// @param start current position to slice from bytes
    /// @return uint8 sliced from bytes
    function sliceUInt8(bytes memory bs, uint start) internal pure returns (uint8) {
        require(bs.length >= start + 1, "slicing out of range");
        return uint8(bs[start]);
    }

    /// @notice slice uint16 from bytes starting at a given index
    /// @param bs bytes to slice from
    /// @param start current position to slice from bytes
    /// @return uint16 sliced from bytes
    function sliceUInt16(bytes memory bs, uint start) internal pure returns (uint16) {
        require(bs.length >= start + 2, "slicing out of range");
        bytes2 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return uint16(x);
    }

    /// @notice slice uint32 from bytes starting at a given index
    /// @param bs bytes to slice from
    /// @param start current position to slice from bytes
    /// @return uint32 sliced from bytes
    function sliceUInt32(bytes memory bs, uint start) internal pure returns (uint32) {
        require(bs.length >= start + 4, "slicing out of range");
        bytes4 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return uint32(x);
    }

    /// @notice slice uint64 from bytes starting at a given index
    /// @param bs bytes to slice from
    /// @param start current position to slice from bytes
    /// @return uint64 sliced from bytes
    function sliceUInt64(bytes memory bs, uint start) internal pure returns (uint64) {
        require(bs.length >= start + 8, "slicing out of range");
        bytes8 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }
        return uint64(x);
    }

    /// @notice Parse cbor header for major type and extra info.
    /// @param cbor cbor encoded bytes to parse from
    /// @param byteIndex current position to read on the cbor encoded bytes
    /// @return major type, extra info and the byte index after moving past header bytes
    function parseCborHeader(bytes memory cbor, uint byteIndex) internal pure returns (uint8, uint64, uint) {
        uint8 first = sliceUInt8(cbor, byteIndex);
        byteIndex += 1;
        uint8 maj = (first & 0xe0) >> 5;
        uint8 low = first & 0x1f;
        // We don't handle CBOR headers with extra > 27, i.e. no indefinite lengths
        require(low < 28, "cannot handle headers with extra > 27");

        // extra is lower bits
        if (low < 24) {
            return (maj, low, byteIndex);
        }

        // extra in next byte
        if (low == 24) {
            uint8 next = sliceUInt8(cbor, byteIndex);
            byteIndex += 1;
            require(next >= 24, "invalid cbor"); // otherwise this is invalid cbor
            return (maj, next, byteIndex);
        }

        // extra in next 2 bytes
        if (low == 25) {
            uint16 extra16 = sliceUInt16(cbor, byteIndex);
            byteIndex += 2;
            return (maj, extra16, byteIndex);
        }

        // extra in next 4 bytes
        if (low == 26) {
            uint32 extra32 = sliceUInt32(cbor, byteIndex);
            byteIndex += 4;
            return (maj, extra32, byteIndex);
        }

        // extra in next 8 bytes
        assert(low == 27);
        uint64 extra64 = sliceUInt64(cbor, byteIndex);
        byteIndex += 8;
        return (maj, extra64, byteIndex);
    }
}

// File: @ensdomains/buffer/contracts/Buffer.sol


pragma solidity ^0.8.4;

/**
* @dev A library for working with mutable byte buffers in Solidity.
*
* Byte buffers are mutable and expandable, and provide a variety of primitives
* for appending to them. At any time you can fetch a bytes object containing the
* current contents of the buffer. The bytes object should not be stored between
* operations, as it may change due to resizing of the buffer.
*/
library Buffer {
    /**
    * @dev Represents a mutable buffer. Buffers have a current value (buf) and
    *      a capacity. The capacity may be longer than the current value, in
    *      which case it can be extended without the need to allocate more memory.
    */
    struct buffer {
        bytes buf;
        uint capacity;
    }

    /**
    * @dev Initializes a buffer with an initial capacity.
    * @param buf The buffer to initialize.
    * @param capacity The number of bytes of space to allocate the buffer.
    * @return The buffer, for chaining.
    */
    function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {
        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        // Allocate space for the buffer data
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            let fpm := add(32, add(ptr, capacity))
            if lt(fpm, ptr) {
                revert(0, 0)
            }
            mstore(0x40, fpm)
        }
        return buf;
    }

    /**
    * @dev Initializes a new buffer from an existing bytes object.
    *      Changes to the buffer may mutate the original value.
    * @param b The bytes object to initialize the buffer with.
    * @return A new buffer.
    */
    function fromBytes(bytes memory b) internal pure returns(buffer memory) {
        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint capacity) private pure {
        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    /**
    * @dev Sets buffer length to 0.
    * @param buf The buffer to truncate.
    * @return The original buffer, for chaining..
    */
    function truncate(buffer memory buf) internal pure returns (buffer memory) {
        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }

    /**
    * @dev Appends len bytes of a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to copy.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data, uint len) internal pure returns(buffer memory) {
        require(len <= data.length);

        uint off = buf.buf.length;
        uint newCapacity = off + len;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint dest;
        uint src;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Length of existing buffer data
            let buflen := mload(bufptr)
            // Start address = buffer address + offset + sizeof(buffer length)
            dest := add(add(bufptr, 32), off)
            // Update buffer length if we're extending it
            if gt(newCapacity, buflen) {
                mstore(bufptr, newCapacity)
            }
            src := add(data, 32)
        }

        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        unchecked {
            uint mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }

        return buf;
    }

    /**
    * @dev Appends a byte string to a buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {
        return append(buf, data, data.length);
    }

    /**
    * @dev Appends a byte to the buffer. Resizes if doing so would exceed the
    *      capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint offPlusOne = off + 1;
        if (off >= buf.capacity) {
            resize(buf, offPlusOne * 2);
        }

        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + off
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            // Update buffer length if we extended it
            if gt(offPlusOne, mload(bufptr)) {
                mstore(bufptr, offPlusOne)
            }
        }

        return buf;
    }

    /**
    * @dev Appends len bytes of bytes32 to a buffer. Resizes if doing so would
    *      exceed the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @param len The number of bytes to write (left-aligned).
    * @return The original buffer, for chaining.
    */
    function append(buffer memory buf, bytes32 data, uint len) private pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        unchecked {
            uint mask = (256 ** len) - 1;
            // Right-align data
            data = data >> (8 * (32 - len));
            assembly {
                // Memory address of the buffer data
                let bufptr := mload(buf)
                // Address = buffer address + sizeof(buffer length) + newCapacity
                let dest := add(bufptr, newCapacity)
                mstore(dest, or(and(mload(dest), not(mask)), data))
                // Update buffer length if we extended it
                if gt(newCapacity, mload(bufptr)) {
                    mstore(bufptr, newCapacity)
                }
            }
        }
        return buf;
    }

    /**
    * @dev Appends a bytes20 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chhaining.
    */
    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {
        return append(buf, bytes32(data), 20);
    }

    /**
    * @dev Appends a bytes32 to the buffer. Resizes if doing so would exceed
    *      the capacity of the buffer.
    * @param buf The buffer to append to.
    * @param data The data to append.
    * @return The original buffer, for chaining.
    */
    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {
        return append(buf, data, 32);
    }

    /**
     * @dev Appends a byte to the end of the buffer. Resizes if doing so would
     *      exceed the capacity of the buffer.
     * @param buf The buffer to append to.
     * @param data The data to append.
     * @param len The number of bytes to write (right-aligned).
     * @return The original buffer.
     */
    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {
        uint off = buf.buf.length;
        uint newCapacity = len + off;
        if (newCapacity > buf.capacity) {
            resize(buf, newCapacity * 2);
        }

        uint mask = (256 ** len) - 1;
        assembly {
            // Memory address of the buffer data
            let bufptr := mload(buf)
            // Address = buffer address + sizeof(buffer length) + newCapacity
            let dest := add(bufptr, newCapacity)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            // Update buffer length if we extended it
            if gt(newCapacity, mload(bufptr)) {
                mstore(bufptr, newCapacity)
            }
        }
        return buf;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/Leb128.sol

/*******************************************************************************
 *   (c) 2023 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;


/// @notice This library implement the leb128
/// @author Zondax AG
library Leb128 {
    using Buffer for Buffer.buffer;

    /// @notice encode a unsigned integer 64bits into bytes
    /// @param value the actor ID to encode
    /// @return result return the value in bytes
    function encodeUnsignedLeb128FromUInt64(uint64 value) internal pure returns (Buffer.buffer memory result) {
        while (true) {
            uint64 byte_ = value & 0x7f;
            value >>= 7;
            if (value == 0) {
                result.appendUint8(uint8(byte_));
                return result;
            }
            result.appendUint8(uint8(byte_ | 0x80));
        }
    }
}

// File: solidity-cborutils/contracts/CBOR.sol


pragma solidity ^0.8.4;


/**
* @dev A library for populating CBOR encoded payload in Solidity.
*
* https://datatracker.ietf.org/doc/html/rfc7049
*
* The library offers various write* and start* methods to encode values of different types.
* The resulted buffer can be obtained with data() method.
* Encoding of primitive types is staightforward, whereas encoding of sequences can result
* in an invalid CBOR if start/write/end flow is violated.
* For the purpose of gas saving, the library does not verify start/write/end flow internally,
* except for nested start/end pairs.
*/

library CBOR {
    using Buffer for Buffer.buffer;

    struct CBORBuffer {
        Buffer.buffer buf;
        uint256 depth;
    }

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    uint8 private constant CBOR_FALSE = 20;
    uint8 private constant CBOR_TRUE = 21;
    uint8 private constant CBOR_NULL = 22;
    uint8 private constant CBOR_UNDEFINED = 23;

    function create(uint256 capacity) internal pure returns(CBORBuffer memory cbor) {
        Buffer.init(cbor.buf, capacity);
        cbor.depth = 0;
        return cbor;
    }

    function data(CBORBuffer memory buf) internal pure returns(bytes memory) {
        require(buf.depth == 0, "Invalid CBOR");
        return buf.buf.buf;
    }

    function writeUInt256(CBORBuffer memory buf, uint256 value) internal pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
        writeBytes(buf, abi.encode(value));
    }

    function writeInt256(CBORBuffer memory buf, int256 value) internal pure {
        if (value < 0) {
            buf.buf.appendUint8(
                uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM)
            );
            writeBytes(buf, abi.encode(uint256(-1 - value)));
        } else {
            writeUInt256(buf, uint256(value));
        }
    }

    function writeUInt64(CBORBuffer memory buf, uint64 value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_INT, value);
    }

    function writeInt64(CBORBuffer memory buf, int64 value) internal pure {
        if(value >= 0) {
            writeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
        } else{
            writeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(-1 - value));
        }
    }

    function writeBytes(CBORBuffer memory buf, bytes memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
        buf.buf.append(value);
    }

    function writeString(CBORBuffer memory buf, string memory value) internal pure {
        writeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
        buf.buf.append(bytes(value));
    }

    function writeBool(CBORBuffer memory buf, bool value) internal pure {
        writeContentFree(buf, value ? CBOR_TRUE : CBOR_FALSE);
    }

    function writeNull(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_NULL);
    }

    function writeUndefined(CBORBuffer memory buf) internal pure {
        writeContentFree(buf, CBOR_UNDEFINED);
    }

    function startArray(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
        buf.depth += 1;
    }

    function startFixedArray(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_ARRAY, length);
    }

    function startMap(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
        buf.depth += 1;
    }

    function startFixedMap(CBORBuffer memory buf, uint64 length) internal pure {
        writeDefiniteLengthType(buf, MAJOR_TYPE_MAP, length);
    }

    function endSequence(CBORBuffer memory buf) internal pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
        buf.depth -= 1;
    }

    function writeKVString(CBORBuffer memory buf, string memory key, string memory value) internal pure {
        writeString(buf, key);
        writeString(buf, value);
    }

    function writeKVBytes(CBORBuffer memory buf, string memory key, bytes memory value) internal pure {
        writeString(buf, key);
        writeBytes(buf, value);
    }

    function writeKVUInt256(CBORBuffer memory buf, string memory key, uint256 value) internal pure {
        writeString(buf, key);
        writeUInt256(buf, value);
    }

    function writeKVInt256(CBORBuffer memory buf, string memory key, int256 value) internal pure {
        writeString(buf, key);
        writeInt256(buf, value);
    }

    function writeKVUInt64(CBORBuffer memory buf, string memory key, uint64 value) internal pure {
        writeString(buf, key);
        writeUInt64(buf, value);
    }

    function writeKVInt64(CBORBuffer memory buf, string memory key, int64 value) internal pure {
        writeString(buf, key);
        writeInt64(buf, value);
    }

    function writeKVBool(CBORBuffer memory buf, string memory key, bool value) internal pure {
        writeString(buf, key);
        writeBool(buf, value);
    }

    function writeKVNull(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeNull(buf);
    }

    function writeKVUndefined(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        writeUndefined(buf);
    }

    function writeKVMap(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startMap(buf);
    }

    function writeKVArray(CBORBuffer memory buf, string memory key) internal pure {
        writeString(buf, key);
        startArray(buf);
    }

    function writeFixedNumeric(
        CBORBuffer memory buf,
        uint8 major,
        uint64 value
    ) private pure {
        if (value <= 23) {
            buf.buf.appendUint8(uint8((major << 5) | value));
        } else if (value <= 0xFF) {
            buf.buf.appendUint8(uint8((major << 5) | 24));
            buf.buf.appendInt(value, 1);
        } else if (value <= 0xFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 25));
            buf.buf.appendInt(value, 2);
        } else if (value <= 0xFFFFFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 26));
            buf.buf.appendInt(value, 4);
        } else {
            buf.buf.appendUint8(uint8((major << 5) | 27));
            buf.buf.appendInt(value, 8);
        }
    }

    function writeIndefiniteLengthType(CBORBuffer memory buf, uint8 major)
        private
        pure
    {
        buf.buf.appendUint8(uint8((major << 5) | 31));
    }

    function writeDefiniteLengthType(CBORBuffer memory buf, uint8 major, uint64 length)
        private
        pure
    {
        writeFixedNumeric(buf, major, length);
    }

    function writeContentFree(CBORBuffer memory buf, uint8 value) private pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_CONTENT_FREE << 5) | value));
    }
}
// File: @zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;


/// @title Filecoin actors' common types for Solidity.
/// @author Zondax AG
library CommonTypes {
    uint constant UniversalReceiverHookMethodNum = 3726118371;

    /// @param idx index for the failure in batch
    /// @param code failure code
    struct FailCode {
        uint32 idx;
        uint32 code;
    }

    /// @param success_count total successes in batch
    /// @param fail_codes list of failures code and index for each failure in batch
    struct BatchReturn {
        uint32 success_count;
        FailCode[] fail_codes;
    }

    /// @param type_ asset type
    /// @param payload payload corresponding to asset type
    struct UniversalReceiverParams {
        uint32 type_;
        bytes payload;
    }

    /// @param val contains the actual arbitrary number written as binary
    /// @param neg indicates if val is negative or not
    struct BigInt {
        bytes val;
        bool neg;
    }

    /// @param data filecoin address in bytes format
    struct FilAddress {
        bytes data;
    }

    /// @param data cid in bytes format
    struct Cid {
        bytes data;
    }

    /// @param data deal proposal label in bytes format (it can be utf8 string or arbitrary bytes string).
    /// @param isString indicates if the data is string or raw bytes
    struct DealLabel {
        bytes data;
        bool isString;
    }

    type FilActorId is uint64;

    type ChainEpoch is int64;
}

// File: @zondax/filecoin-solidity/contracts/v0.8/types/AccountTypes.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;


/// @title Filecoin account actor types for Solidity.
/// @author Zondax AG
library AccountTypes {
    uint constant AuthenticateMessageMethodNum = 2643134072;

    /// @param it should be a raw byte of signature, NOT a serialized signature object with a signatureType.
    /// @param message The message which is signed by the corresponding account address.
    struct AuthenticateMessageParams {
        bytes signature;
        bytes message;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;




/// @notice This library is a set a functions that allows to handle filecoin addresses conversions and validations
/// @author Zondax AG
library FilAddresses {
    using Buffer for Buffer.buffer;

    error InvalidAddress();

    /// @notice allow to get a FilAddress from an eth address
    /// @param addr eth address to convert
    /// @return new filecoin address
    function fromEthAddress(address addr) internal pure returns (CommonTypes.FilAddress memory) {
        return CommonTypes.FilAddress(abi.encodePacked(hex"040a", addr));
    }

    /// @notice allow to create a Filecoin address from an actorID
    /// @param actorID uint64 actorID
    /// @return address filecoin address
    function fromActorID(uint64 actorID) internal pure returns (CommonTypes.FilAddress memory) {
        Buffer.buffer memory result = Leb128.encodeUnsignedLeb128FromUInt64(actorID);
        return CommonTypes.FilAddress(abi.encodePacked(hex"00", result.buf));
    }

    /// @notice allow to create a Filecoin address from bytes
    /// @param data address in bytes format
    /// @return filecoin address
    function fromBytes(bytes memory data) internal pure returns (CommonTypes.FilAddress memory) {
        CommonTypes.FilAddress memory newAddr = CommonTypes.FilAddress(data);
        if (!validate(newAddr)) {
            revert InvalidAddress();
        }

        return newAddr;
    }

    /// @notice allow to validate if an address is valid or not
    /// @dev we are only validating known address types. If the type is not known, the default value is true
    /// @param addr the filecoin address to validate
    /// @return whether the address is valid or not
    function validate(CommonTypes.FilAddress memory addr) internal pure returns (bool) {
        if (addr.data[0] == 0x00) {
            return addr.data.length <= 10;
        } else if (addr.data[0] == 0x01 || addr.data[0] == 0x02) {
            return addr.data.length == 21;
        } else if (addr.data[0] == 0x03) {
            return addr.data.length == 49;
        } else if (addr.data[0] == 0x04) {
            return addr.data.length <= 64;
        }

        return addr.data.length <= 256;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/Misc.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;


/// @title Library containing miscellaneous functions used on the project
/// @author Zondax AG
library Misc {
    uint64 constant DAG_CBOR_CODEC = 0x71;
    uint64 constant CBOR_CODEC = 0x51;
    uint64 constant NONE_CODEC = 0x00;

    // Code taken from Openzeppelin repo
    // Link: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0320a718e8e07b1d932f5acb8ad9cec9d9eed99b/contracts/utils/math/SignedMath.sol#L37-L42
    /// @notice get the abs from a signed number
    /// @param n number to get abs from
    /// @return unsigned number
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }

    /// @notice validate if an address exists or not
    /// @dev read this article for more information https://blog.finxter.com/how-to-find-out-if-an-ethereum-address-is-a-contract/
    /// @param addr address to check
    /// @return whether the address exists or not
    function addressExists(address addr) internal view returns (bool) {
        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return codehash != 0x0;
    }

    /// Returns the data size required by CBOR.writeFixedNumeric
    function getPrefixSize(uint256 data_size) internal pure returns (uint256) {
        if (data_size <= 23) {
            return 1;
        } else if (data_size <= 0xFF) {
            return 2;
        } else if (data_size <= 0xFFFF) {
            return 3;
        } else if (data_size <= 0xFFFFFFFF) {
            return 5;
        }
        return 9;
    }

    function getBytesSize(bytes memory value) internal pure returns (uint256) {
        return getPrefixSize(value.length) + value.length;
    }

    function getCidSize(bytes memory value) internal pure returns (uint256) {
        return getPrefixSize(2) + value.length;
    }

    function getFilActorIdSize(CommonTypes.FilActorId value) internal pure returns (uint256) {
        uint64 val = CommonTypes.FilActorId.unwrap(value);
        return getPrefixSize(uint256(val));
    }

    function getChainEpochSize(CommonTypes.ChainEpoch value) internal pure returns (uint256) {
        int64 val = CommonTypes.ChainEpoch.unwrap(value);
        if (val >= 0) {
            return getPrefixSize(uint256(uint64(val)));
        } else {
            return getPrefixSize(uint256(uint64(-1 - val)));
        }
    }

    function getBoolSize() internal pure returns (uint256) {
        return getPrefixSize(1);
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/BigInts.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;




/// @notice This library is a set a functions that allows to handle filecoin addresses conversions and validations
/// @author Zondax AG
library BigInts {
    uint256 constant MAX_UINT = (2 ** 256) - 1;
    uint256 constant MAX_INT = ((2 ** 256) / 2) - 1;

    error NegativeValueNotAllowed();

    /// @notice allow to get a BigInt from a uint256 value
    /// @param value uint256 number
    /// @return new BigInt
    function fromUint256(uint256 value) internal view returns (CommonTypes.BigInt memory) {
        BigNumber memory bigNum = BigNumbers.init(value, false);
        return CommonTypes.BigInt(bigNum.val, bigNum.neg);
    }

    /// @notice allow to get a BigInt from a int256 value
    /// @param value int256 number
    /// @return new BigInt
    function fromInt256(int256 value) internal view returns (CommonTypes.BigInt memory) {
        uint256 valueAbs = Misc.abs(value);
        BigNumber memory bigNum = BigNumbers.init(valueAbs, value < 0);
        return CommonTypes.BigInt(bigNum.val, bigNum.neg);
    }

    /// @notice allow to get a uint256 from a BigInt value.
    /// @notice If the value is negative, it will generate an error.
    /// @param value BigInt number
    /// @return a uint256 value and flog that indicates whether it was possible to convert or not (the value overflows uint256 type)
    function toUint256(CommonTypes.BigInt memory value) internal view returns (uint256, bool) {
        if (value.neg) {
            revert NegativeValueNotAllowed();
        }

        BigNumber memory max = BigNumbers.init(MAX_UINT, false);
        BigNumber memory bigNumValue = BigNumbers.init(value.val, value.neg);
        if (BigNumbers.gt(bigNumValue, max)) {
            return (0, true);
        }

        return (uint256(bytes32(bigNumValue.val)), false);
    }

    /// @notice allow to get a int256 from a BigInt value.
    /// @notice If the value is grater than what a int256 can store, it will generate an error.
    /// @param value BigInt number
    /// @return a int256 value and flog that indicates whether it was possible to convert or not (the value overflows int256 type)
    function toInt256(CommonTypes.BigInt memory value) internal view returns (int256, bool) {
        BigNumber memory max = BigNumbers.init(MAX_INT, false);
        BigNumber memory bigNumValue = BigNumbers.init(value.val, false);
        if (BigNumbers.gt(bigNumValue, max)) {
            return (0, true);
        }

        int256 parsedValue = int256(uint256(bytes32(bigNumValue.val)));
        return (value.neg ? -1 * parsedValue : parsedValue, false);
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/cbor/AccountCbor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;





/// @title This library is a set of functions meant to handle CBOR parameters serialization and return values deserialization for Account actor exported methods.
/// @author Zondax AG
library AccountCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;

    /// @notice serialize AuthenticateMessageParams struct to cbor in order to pass as arguments to an account actor
    /// @param params AuthenticateMessageParams to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializeAuthenticateMessageParams(AccountTypes.AuthenticateMessageParams memory params) internal pure returns (bytes memory) {
        uint256 capacity = 0;

        capacity += Misc.getPrefixSize(2);
        capacity += Misc.getBytesSize(params.signature);
        capacity += Misc.getBytesSize(params.message);

        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(2);
        buf.writeBytes(params.signature);
        buf.writeBytes(params.message);

        return buf.data();
    }

    /// @notice deserialize AuthenticateMessageParams struct from cbor encoded bytes coming from an account actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of AuthenticateMessageParams created based on parsed data
    function deserializeAuthenticateMessageParams(bytes memory rawResp) internal pure returns (AccountTypes.AuthenticateMessageParams memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.signature, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.message, byteIdx) = rawResp.readBytes(byteIdx);

        return ret;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/utils/Actor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;



/// @title Call actors utilities library, meant to interact with Filecoin builtin actors
/// @author Zondax AG
library Actor {
    /// @notice precompile address for the call_actor precompile
    address constant CALL_ACTOR_ADDRESS = 0xfe00000000000000000000000000000000000003;

    /// @notice precompile address for the call_actor_id precompile
    address constant CALL_ACTOR_ID = 0xfe00000000000000000000000000000000000005;

    /// @notice flag used to indicate that the call_actor or call_actor_id should perform a static_call to the desired actor
    uint64 constant READ_ONLY_FLAG = 0x00000001;

    /// @notice flag used to indicate that the call_actor or call_actor_id should perform a call to the desired actor
    uint64 constant DEFAULT_FLAG = 0x00000000;

    /// @notice the provided address is not valid
    error InvalidAddress(bytes addr);

    /// @notice the smart contract has no enough balance to transfer
    error NotEnoughBalance(uint256 balance, uint256 value);

    /// @notice the provided actor id is not valid
    error InvalidActorID(CommonTypes.FilActorId actorId);

    /// @notice an error happened trying to call the actor
    error FailToCallActor();

    /// @notice the response received is not correct. In some case no response is expected and we received one, or a response was indeed expected and we received none.
    error InvalidResponseLength();

    /// @notice the codec received is not valid
    error InvalidCodec(uint64);

    /// @notice the called actor returned an error as part of its expected behaviour
    error ActorError(int256 errorCode);

    /// @notice the actor is not found
    error ActorNotFound();

    /// @notice allows to interact with an specific actor by its address (bytes format)
    /// @param actor_address actor address (bytes format) to interact with
    /// @param method_num id of the method from the actor to call
    /// @param codec how the request data passed as argument is encoded
    /// @param raw_request encoded arguments to be passed in the call
    /// @param value tokens to be transferred to the called actor
    /// @param static_call indicates if the call will be allowed to change the actor state or not (just read the state)
    /// @return payload (in bytes) with the actual response data (without codec or response code)
    function callByAddress(
        bytes memory actor_address,
        uint256 method_num,
        uint64 codec,
        bytes memory raw_request,
        uint256 value,
        bool static_call
    ) internal returns (bytes memory) {
        if (actor_address.length < 2) {
            revert InvalidAddress(actor_address);
        }

        validatePrecompileCall(CALL_ACTOR_ADDRESS, value);

        // We have to delegate-call the call-actor precompile because the call-actor precompile will
        // call the target actor on our behalf. This will _not_ delegate to the target `actor_address`.
        //
        // Specifically:
        //
        // - `static_call == false`: `CALLER (you) --(DELEGATECALL)-> CALL_ACTOR_PRECOMPILE --(CALL)-> actor_address
        // - `static_call == true`:  `CALLER (you) --(DELEGATECALL)-> CALL_ACTOR_PRECOMPILE --(STATICCALL)-> actor_address
        (bool success, bytes memory data) = address(CALL_ACTOR_ADDRESS).delegatecall(
            abi.encode(uint64(method_num), value, static_call ? READ_ONLY_FLAG : DEFAULT_FLAG, codec, raw_request, actor_address)
        );
        if (!success) {
            revert FailToCallActor();
        }

        return readRespData(data);
    }

    /// @notice allows to interact with an specific actor by its id (uint64)
    /// @param target actor id (uint64) to interact with
    /// @param method_num id of the method from the actor to call
    /// @param codec how the request data passed as argument is encoded
    /// @param raw_request encoded arguments to be passed in the call
    /// @param value tokens to be transferred to the called actor
    /// @param static_call indicates if the call will be allowed to change the actor state or not (just read the state)
    /// @return payload (in bytes) with the actual response data (without codec or response code)
    function callByID(
        CommonTypes.FilActorId target,
        uint256 method_num,
        uint64 codec,
        bytes memory raw_request,
        uint256 value,
        bool static_call
    ) internal returns (bytes memory) {
        validatePrecompileCall(CALL_ACTOR_ID, value);

        (bool success, bytes memory data) = address(CALL_ACTOR_ID).delegatecall(
            abi.encode(uint64(method_num), value, static_call ? READ_ONLY_FLAG : DEFAULT_FLAG, codec, raw_request, target)
        );
        if (!success) {
            revert FailToCallActor();
        }

        return readRespData(data);
    }

    /// @notice allows to run some generic validations before calling the precompile actor
    /// @param addr precompile actor address to run check to
    /// @param value tokens to be transferred to the called actor
    function validatePrecompileCall(address addr, uint256 value) internal view {
        uint balance = address(this).balance;
        if (balance < value) {
            revert NotEnoughBalance(balance, value);
        }

        bool actorExists = Misc.addressExists(addr);
        if (!actorExists) {
            revert ActorNotFound();
        }
    }

    /// @notice allows to interact with an non-singleton actors by its id (uint64)
    /// @param target actor id (uint64) to interact with
    /// @param method_num id of the method from the actor to call
    /// @param codec how the request data passed as argument is encoded
    /// @param raw_request encoded arguments to be passed in the call
    /// @param value tokens to be transfered to the called actor
    /// @param static_call indicates if the call will be allowed to change the actor state or not (just read the state)
    /// @dev it requires the id to be bigger than 99, as singleton actors are smaller than that
    function callNonSingletonByID(
        CommonTypes.FilActorId target,
        uint256 method_num,
        uint64 codec,
        bytes memory raw_request,
        uint256 value,
        bool static_call
    ) internal returns (bytes memory) {
        if (CommonTypes.FilActorId.unwrap(target) < 100) {
            revert InvalidActorID(target);
        }

        return callByID(target, method_num, codec, raw_request, value, static_call);
    }

    /// @notice parse the response an actor returned
    /// @notice it will validate the return code (success) and the codec (valid one)
    /// @param raw_response raw data (bytes) the actor returned
    /// @return the actual raw data (payload, in bytes) to be parsed according to the actor and method called
    function readRespData(bytes memory raw_response) internal pure returns (bytes memory) {
        (int256 exit, uint64 return_codec, bytes memory return_value) = abi.decode(raw_response, (int256, uint64, bytes));

        if (return_codec == Misc.NONE_CODEC) {
            if (return_value.length != 0) {
                revert InvalidResponseLength();
            }
        } else if (return_codec == Misc.CBOR_CODEC || return_codec == Misc.DAG_CBOR_CODEC) {
            if (return_value.length == 0) {
                revert InvalidResponseLength();
            }
        } else {
            revert InvalidCodec(return_codec);
        }

        if (exit != 0) {
            revert ActorError(exit);
        }

        return return_value;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;


/// @title This library is a set of functions meant to handle CBOR serialization and deserialization for BigInt type
/// @author Zondax AG
library BigIntCBOR {
    /// @notice serialize BigInt instance to bytes
    /// @param num BigInt instance to serialize
    /// @return serialized BigInt as bytes
    function serializeBigInt(CommonTypes.BigInt memory num) internal pure returns (bytes memory) {
        bytes memory raw = new bytes(num.val.length + 1);

        raw[0] = num.neg == true ? bytes1(0x01) : bytes1(0x00);

        uint index = 1;
        for (uint i = 0; i < num.val.length; i++) {
            raw[index] = num.val[i];
            index++;
        }

        return raw;
    }

    /// @notice deserialize big int (encoded as bytes) to BigInt instance
    /// @param raw as bytes to parse
    /// @return parsed BigInt instance
    function deserializeBigInt(bytes memory raw) internal pure returns (CommonTypes.BigInt memory) {
        if (raw.length == 0) {
            return CommonTypes.BigInt(hex"00", false);
        }

        bytes memory val = new bytes(raw.length - 1);
        bool neg = false;

        if (raw[0] == 0x01) {
            neg = true;
        }

        for (uint i = 1; i < raw.length; i++) {
            val[i - 1] = raw[i];
        }

        return CommonTypes.BigInt(val, neg);
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/cbor/BytesCbor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;






/// @title This library is a set of functions meant to handle CBOR serialization and deserialization for bytes
/// @author Zondax AG
library BytesCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for bytes;

    /// @notice serialize raw bytes as cbor bytes string encoded
    /// @param data raw data in bytes
    /// @return encoded cbor bytes
    function serializeBytes(bytes memory data) internal pure returns (bytes memory) {
        uint256 capacity = Misc.getBytesSize(data);

        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.writeBytes(data);

        return buf.data();
    }

    /// @notice serialize raw address (in bytes) as cbor bytes string encoded (how an address is passed to filecoin actors)
    /// @param addr raw address in bytes
    /// @return encoded address as cbor bytes
    function serializeAddress(bytes memory addr) internal pure returns (bytes memory) {
        return serializeBytes(addr);
    }

    /// @notice encoded null value as cbor
    /// @return cbor encoded null
    function serializeNull() internal pure returns (bytes memory) {
        CBOR.CBORBuffer memory buf = CBOR.create(1);

        buf.writeNull();

        return buf.data();
    }

    /// @notice deserialize cbor encoded filecoin address to bytes
    /// @param ret cbor encoded filecoin address
    /// @return raw bytes representing a filecoin address
    function deserializeAddress(bytes memory ret) internal pure returns (bytes memory) {
        bytes memory addr;
        uint byteIdx = 0;

        (addr, byteIdx) = ret.readBytes(byteIdx);

        return addr;
    }

    /// @notice deserialize cbor encoded string
    /// @param ret cbor encoded string (in bytes)
    /// @return decoded string
    function deserializeString(bytes memory ret) internal pure returns (string memory) {
        string memory response;
        uint byteIdx = 0;

        (response, byteIdx) = ret.readString(byteIdx);

        return response;
    }

    /// @notice deserialize cbor encoded bool
    /// @param ret cbor encoded bool (in bytes)
    /// @return decoded bool
    function deserializeBool(bytes memory ret) internal pure returns (bool) {
        bool response;
        uint byteIdx = 0;

        (response, byteIdx) = ret.readBool(byteIdx);

        return response;
    }

    /// @notice deserialize cbor encoded BigInt
    /// @param ret cbor encoded BigInt (in bytes)
    /// @return decoded BigInt
    /// @dev BigInts are cbor encoded as bytes string first. That is why it unwraps the cbor encoded bytes first, and then parse the result into BigInt
    function deserializeBytesBigInt(bytes memory ret) internal pure returns (CommonTypes.BigInt memory) {
        bytes memory tmp;
        uint byteIdx = 0;

        if (ret.length > 0) {
            (tmp, byteIdx) = ret.readBytes(byteIdx);
            if (tmp.length > 0) {
                return tmp.deserializeBigInt();
            }
        }

        return CommonTypes.BigInt(new bytes(0), false);
    }

    /// @notice deserialize cbor encoded uint64
    /// @param rawResp cbor encoded uint64 (in bytes)
    /// @return decoded uint64
    function deserializeUint64(bytes memory rawResp) internal pure returns (uint64) {
        uint byteIdx = 0;
        uint64 value;

        (value, byteIdx) = rawResp.readUInt64(byteIdx);
        return value;
    }

    /// @notice deserialize cbor encoded int64
    /// @param rawResp cbor encoded int64 (in bytes)
    /// @return decoded int64
    function deserializeInt64(bytes memory rawResp) internal pure returns (int64) {
        uint byteIdx = 0;
        int64 value;

        (value, byteIdx) = rawResp.readInt64(byteIdx);
        return value;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/cbor/FilecoinCbor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;







/// @title This library is a set of functions meant to handle CBOR serialization and deserialization for general data types on the filecoin network.
/// @author Zondax AG
library FilecoinCBOR {
    using Buffer for Buffer.buffer;
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for *;
    using BigIntCBOR for *;

    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant TAG_TYPE_CID_CODE = 42;
    uint8 private constant PAYLOAD_LEN_8_BITS = 24;

    /// @notice Write a CID into a CBOR buffer.
    /// @dev The CBOR major will be 6 (type 'tag') and the tag type value is 42, as per CBOR tag assignments.
    /// @dev https://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml
    /// @param buf buffer containing the actual CBOR serialization process
    /// @param value CID value to serialize as CBOR
    function writeCid(CBOR.CBORBuffer memory buf, bytes memory value) internal pure {
        buf.buf.appendUint8(uint8(((MAJOR_TYPE_TAG << 5) | PAYLOAD_LEN_8_BITS)));
        buf.buf.appendUint8(TAG_TYPE_CID_CODE);
        // See https://ipld.io/specs/codecs/dag-cbor/spec/#links for explanation on 0x00 prefix.
        buf.writeBytes(bytes.concat(hex'00', value));
    }

    function readCid(bytes memory cborData, uint byteIdx) internal pure returns (CommonTypes.Cid memory, uint) {
        uint8 maj;
        uint value;

        (maj, value, byteIdx) = cborData.parseCborHeader(byteIdx);
        require(maj == MAJOR_TYPE_TAG, "expected major type tag when parsing cid");
        require(value == TAG_TYPE_CID_CODE, "expected tag 42 when parsing cid");

        bytes memory raw;
        (raw, byteIdx) = cborData.readBytes(byteIdx);
        require(raw[0] == 0x00, "expected first byte to be 0 when parsing cid");

        // Pop off the first byte, which corresponds to the historical multibase 0x00 byte.
        // https://ipld.io/specs/codecs/dag-cbor/spec/#links
        CommonTypes.Cid memory ret;
        ret.data = new bytes(raw.length - 1);
        for (uint256 i = 1; i < raw.length; i++) {
            ret.data[i-1] = raw[i];
        }

        return (ret, byteIdx);
    }

    /// @notice serialize filecoin address to cbor encoded
    /// @param addr filecoin address to serialize
    /// @return cbor serialized data as bytes
    function serializeAddress(CommonTypes.FilAddress memory addr) internal pure returns (bytes memory) {
        uint256 capacity = Misc.getBytesSize(addr.data);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.writeBytes(addr.data);

        return buf.data();
    }

    /// @notice serialize a BigInt value wrapped in a cbor fixed array.
    /// @param value BigInt to serialize as cbor inside an
    /// @return cbor serialized data as bytes
    function serializeArrayBigInt(CommonTypes.BigInt memory value) internal pure returns (bytes memory) {
        uint256 capacity = 0;
        bytes memory valueBigInt = value.serializeBigInt();

        capacity += Misc.getPrefixSize(1);
        capacity += Misc.getBytesSize(valueBigInt);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(1);
        buf.writeBytes(value.serializeBigInt());

        return buf.data();
    }

    /// @notice serialize a FilAddress value wrapped in a cbor fixed array.
    /// @param addr FilAddress to serialize as cbor inside an
    /// @return cbor serialized data as bytes
    function serializeArrayFilAddress(CommonTypes.FilAddress memory addr) internal pure returns (bytes memory) {
        uint256 capacity = 0;

        capacity += Misc.getPrefixSize(1);
        capacity += Misc.getBytesSize(addr.data);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(1);
        buf.writeBytes(addr.data);

        return buf.data();
    }

    /// @notice deserialize a FilAddress wrapped on a cbor fixed array coming from a actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of FilAddress created based on parsed data
    function deserializeArrayFilAddress(bytes memory rawResp) internal pure returns (CommonTypes.FilAddress memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        require(len == 1, "Wrong numbers of parameters (should find 1)");

        (ret.data, byteIdx) = rawResp.readBytes(byteIdx);

        return ret;
    }

    /// @notice deserialize a BigInt wrapped on a cbor fixed array coming from a actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of BigInt created based on parsed data
    function deserializeArrayBigInt(bytes memory rawResp) internal pure returns (CommonTypes.BigInt memory) {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 1);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        return tmp.deserializeBigInt();
    }

    /// @notice serialize UniversalReceiverParams struct to cbor in order to pass as arguments to an actor
    /// @param params UniversalReceiverParams to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializeUniversalReceiverParams(CommonTypes.UniversalReceiverParams memory params) internal pure returns (bytes memory) {
        uint256 capacity = 0;

        capacity += Misc.getPrefixSize(2);
        capacity += Misc.getPrefixSize(params.type_);
        capacity += Misc.getBytesSize(params.payload);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(2);
        buf.writeUInt64(params.type_);
        buf.writeBytes(params.payload);

        return buf.data();
    }

    /// @notice deserialize UniversalReceiverParams cbor to struct when receiving a message
    /// @param rawResp cbor encoded response
    /// @return ret new instance of UniversalReceiverParams created based on parsed data
    function deserializeUniversalReceiverParams(bytes memory rawResp) internal pure returns (CommonTypes.UniversalReceiverParams memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        require(len == 2, "Wrong numbers of parameters (should find 2)");

        (ret.type_, byteIdx) = rawResp.readUInt32(byteIdx);
        (ret.payload, byteIdx) = rawResp.readBytes(byteIdx);
    }

    /// @notice attempt to read a FilActorId value
    /// @param rawResp cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return a FilActorId decoded from input bytes and the byte index after moving past the value
    function readFilActorId(bytes memory rawResp, uint byteIdx) internal pure returns (CommonTypes.FilActorId, uint) {
        uint64 tmp = 0;

        (tmp, byteIdx) = rawResp.readUInt64(byteIdx);
        return (CommonTypes.FilActorId.wrap(tmp), byteIdx);
    }

    /// @notice write FilActorId into a cbor buffer
    /// @dev FilActorId is just wrapping a uint64
    /// @param buf buffer containing the actual cbor serialization process
    /// @param id FilActorId to serialize as cbor
    function writeFilActorId(CBOR.CBORBuffer memory buf, CommonTypes.FilActorId id) internal pure {
        buf.writeUInt64(CommonTypes.FilActorId.unwrap(id));
    }

    /// @notice attempt to read a ChainEpoch value
    /// @param rawResp cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return a ChainEpoch decoded from input bytes and the byte index after moving past the value
    function readChainEpoch(bytes memory rawResp, uint byteIdx) internal pure returns (CommonTypes.ChainEpoch, uint) {
        int64 tmp = 0;

        (tmp, byteIdx) = rawResp.readInt64(byteIdx);
        return (CommonTypes.ChainEpoch.wrap(tmp), byteIdx);
    }

    /// @notice write ChainEpoch into a cbor buffer
    /// @dev ChainEpoch is just wrapping a int64
    /// @param buf buffer containing the actual cbor serialization process
    /// @param id ChainEpoch to serialize as cbor
    function writeChainEpoch(CBOR.CBORBuffer memory buf, CommonTypes.ChainEpoch id) internal pure {
        buf.writeInt64(CommonTypes.ChainEpoch.unwrap(id));
    }

    /// @notice write DealLabel into a cbor buffer
    /// @param buf buffer containing the actual cbor serialization process
    /// @param label DealLabel to serialize as cbor
    function writeDealLabel(CBOR.CBORBuffer memory buf, CommonTypes.DealLabel memory label) internal pure {
        label.isString ? buf.writeString(string(label.data)) : buf.writeBytes(label.data);
    }

    /// @notice deserialize DealLabel cbor to struct when receiving a message
    /// @param rawResp cbor encoded response
    /// @return ret new instance of DealLabel created based on parsed data
    function deserializeDealLabel(bytes memory rawResp) internal pure returns (CommonTypes.DealLabel memory) {
        uint byteIdx = 0;
        CommonTypes.DealLabel memory label;

        (label, byteIdx) = readDealLabel(rawResp, byteIdx);
        return label;
    }

    /// @notice attempt to read a DealLabel value
    /// @param rawResp cbor encoded bytes to parse from
    /// @param byteIdx current position to read on the cbor encoded bytes
    /// @return a DealLabel decoded from input bytes and the byte index after moving past the value
    function readDealLabel(bytes memory rawResp, uint byteIdx) internal pure returns (CommonTypes.DealLabel memory, uint) {
        uint8 maj;
        uint len;

        (maj, len, byteIdx) = CBORDecoder.parseCborHeader(rawResp, byteIdx);
        require(maj == MajByteString || maj == MajTextString, "invalid maj (expected MajByteString or MajTextString)");

        uint max_len = byteIdx + len;
        bytes memory slice = new bytes(len);
        uint slice_index = 0;
        for (uint256 i = byteIdx; i < max_len; i++) {
            slice[slice_index] = rawResp[i];
            slice_index++;
        }

        return (CommonTypes.DealLabel(slice, maj == MajTextString), byteIdx + len);
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;



/// @title Filecoin market actor types for Solidity.
/// @author Zondax AG
library MarketTypes {
    CommonTypes.FilActorId constant ActorID = CommonTypes.FilActorId.wrap(5);
    uint constant AddBalanceMethodNum = 822473126;
    uint constant WithdrawBalanceMethodNum = 2280458852;
    uint constant GetBalanceMethodNum = 726108461;
    uint constant GetDealDataCommitmentMethodNum = 1157985802;
    uint constant GetDealClientMethodNum = 128053329;
    uint constant GetDealProviderMethodNum = 935081690;
    uint constant GetDealLabelMethodNum = 46363526;
    uint constant GetDealTermMethodNum = 163777312;
    uint constant GetDealTotalPriceMethodNum = 4287162428;
    uint constant GetDealClientCollateralMethodNum = 200567895;
    uint constant GetDealProviderCollateralMethodNum = 2986712137;
    uint constant GetDealVerifiedMethodNum = 2627389465;
    uint constant GetDealActivationMethodNum = 2567238399;
    uint constant PublishStorageDealsMethodNum = 2236929350;

    /// @param provider_or_client the address of provider or client.
    /// @param tokenAmount the token amount to withdraw.
    struct WithdrawBalanceParams {
        CommonTypes.FilAddress provider_or_client;
        CommonTypes.BigInt tokenAmount;
    }

    /// @param balance the escrow balance for this address.
    /// @param locked the escrow locked amount for this address.
    struct GetBalanceReturn {
        CommonTypes.BigInt balance;
        CommonTypes.BigInt locked;
    }

    /// @param data the data commitment of this deal.
    /// @param size the size of this deal.
    struct GetDealDataCommitmentReturn {
        bytes data;
        uint64 size;
    }

    /// @param start the chain epoch to start the deal.
    /// @param endthe chain epoch to end the deal.
    struct GetDealTermReturn {
        CommonTypes.ChainEpoch start;
        CommonTypes.ChainEpoch end;
    }

    /// @param activated Epoch at which the deal was activated, or -1.
    /// @param terminated Epoch at which the deal was terminated abnormally, or -1.
    struct GetDealActivationReturn {
        CommonTypes.ChainEpoch activated;
        CommonTypes.ChainEpoch terminated;
    }

    /// @param deals list of deal proposals signed by a client
    struct PublishStorageDealsParams {
        ClientDealProposal[] deals;
    }

    /// @param ids returned storage deal IDs.
    /// @param valid_deals represent all the valid deals.
    struct PublishStorageDealsReturn {
        uint64[] ids;
        bytes valid_deals;
    }

    /// @param piece_cid PieceCID.
    /// @param piece_size the size of the piece.
    /// @param verified_deal if the deal is verified or not.
    /// @param client the address of the storage client.
    /// @param provider the address of the storage provider.
    /// @param label any label that client choose for the deal.
    /// @param start_epoch the chain epoch to start the deal.
    /// @param end_epoch the chain epoch to end the deal.
    /// @param storage_price_per_epoch the token amount to pay to provider per epoch.
    /// @param provider_collateral the token amount as collateral paid by the provider.
    /// @param client_collateral the token amount as collateral paid by the client.
    struct DealProposal {
        CommonTypes.Cid piece_cid;
        uint64 piece_size;
        bool verified_deal;
        CommonTypes.FilAddress client;
        CommonTypes.FilAddress provider;
        CommonTypes.DealLabel label;
        CommonTypes.ChainEpoch start_epoch;
        CommonTypes.ChainEpoch end_epoch;
        CommonTypes.BigInt storage_price_per_epoch;
        CommonTypes.BigInt provider_collateral;
        CommonTypes.BigInt client_collateral;
    }

    /// @param proposal Proposal
    /// @param client_signature the signature signed by the client.
    struct ClientDealProposal {
        DealProposal proposal;
        bytes client_signature;
    }

    struct MarketDealNotifyParams {
        bytes dealProposal;
        uint64 dealId;
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/cbor/MarketCbor.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;










/// @title This library is a set of functions meant to handle CBOR parameters serialization and return values deserialization for Market actor exported methods.
/// @author Zondax AG
library MarketCBOR {
    using CBOR for CBOR.CBORBuffer;
    using CBORDecoder for bytes;
    using BigIntCBOR for *;
    using FilecoinCBOR for *;

    /// @notice serialize WithdrawBalanceParams struct to cbor in order to pass as arguments to the market actor
    /// @param params WithdrawBalanceParams to serialize as cbor
    /// @return response cbor serialized data as bytes
    function serializeWithdrawBalanceParams(MarketTypes.WithdrawBalanceParams memory params) internal pure returns (bytes memory) {
        uint256 capacity = 0;
        bytes memory tokenAmount = params.tokenAmount.serializeBigInt();

        capacity += Misc.getPrefixSize(2);
        capacity += Misc.getBytesSize(params.provider_or_client.data);
        capacity += Misc.getBytesSize(tokenAmount);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(2);
        buf.writeBytes(params.provider_or_client.data);
        buf.writeBytes(tokenAmount);

        return buf.data();
    }

    /// @notice deserialize GetBalanceReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetBalanceReturn created based on parsed data
    function deserializeGetBalanceReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetBalanceReturn memory ret) {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.balance = tmp.deserializeBigInt();

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.locked = tmp.deserializeBigInt();

        return ret;
    }

    /// @notice deserialize GetDealDataCommitmentReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealDataCommitmentReturn created based on parsed data
    function deserializeGetDealDataCommitmentReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealDataCommitmentReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);

        if (len > 0) {
            (ret.data, byteIdx) = rawResp.readBytes(byteIdx);
            (ret.size, byteIdx) = rawResp.readUInt64(byteIdx);
        } else {
            ret.data = new bytes(0);
            ret.size = 0;
        }

        return ret;
    }

    /// @notice deserialize GetDealTermReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealTermReturn created based on parsed data
    function deserializeGetDealTermReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealTermReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.start, byteIdx) = rawResp.readChainEpoch(byteIdx);
        (ret.end, byteIdx) = rawResp.readChainEpoch(byteIdx);

        return ret;
    }

    /// @notice deserialize GetDealActivationReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of GetDealActivationReturn created based on parsed data
    function deserializeGetDealActivationReturn(bytes memory rawResp) internal pure returns (MarketTypes.GetDealActivationReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.activated, byteIdx) = rawResp.readChainEpoch(byteIdx);
        (ret.terminated, byteIdx) = rawResp.readChainEpoch(byteIdx);

        return ret;
    }

    /// @notice serialize PublishStorageDealsParams struct to cbor in order to pass as arguments to the market actor
    /// @param params PublishStorageDealsParams to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializePublishStorageDealsParams(MarketTypes.PublishStorageDealsParams memory params) internal pure returns (bytes memory) {
        uint256 capacity = 0;

        capacity += Misc.getPrefixSize(1);
        capacity += Misc.getPrefixSize(params.deals.length);

        for (uint64 i = 0; i < params.deals.length; i++) {
            capacity += Misc.getPrefixSize(2);
            capacity += Misc.getPrefixSize(11);

            capacity += Misc.getCidSize(params.deals[i].proposal.piece_cid.data);
            capacity += Misc.getPrefixSize(params.deals[i].proposal.piece_size);
            capacity += Misc.getBoolSize();
            capacity += Misc.getBytesSize(params.deals[i].proposal.client.data);
            capacity += Misc.getBytesSize(params.deals[i].proposal.provider.data);
            capacity += Misc.getBytesSize(params.deals[i].proposal.label.data);
            capacity += Misc.getChainEpochSize(params.deals[i].proposal.start_epoch);
            capacity += Misc.getChainEpochSize(params.deals[i].proposal.end_epoch);
            capacity += Misc.getBytesSize(params.deals[i].proposal.storage_price_per_epoch.serializeBigInt());
            capacity += Misc.getBytesSize(params.deals[i].proposal.provider_collateral.serializeBigInt());
            capacity += Misc.getBytesSize(params.deals[i].proposal.client_collateral.serializeBigInt());

            capacity += Misc.getBytesSize(params.deals[i].client_signature);
        }

        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(1);
        buf.startFixedArray(uint64(params.deals.length));

        for (uint64 i = 0; i < params.deals.length; i++) {
            buf.startFixedArray(2);

            buf.startFixedArray(11);

            buf.writeCid(params.deals[i].proposal.piece_cid.data);
            buf.writeUInt64(params.deals[i].proposal.piece_size);
            buf.writeBool(params.deals[i].proposal.verified_deal);
            buf.writeBytes(params.deals[i].proposal.client.data);
            buf.writeBytes(params.deals[i].proposal.provider.data);
            buf.writeDealLabel(params.deals[i].proposal.label);
            buf.writeChainEpoch(params.deals[i].proposal.start_epoch);
            buf.writeChainEpoch(params.deals[i].proposal.end_epoch);
            buf.writeBytes(params.deals[i].proposal.storage_price_per_epoch.serializeBigInt());
            buf.writeBytes(params.deals[i].proposal.provider_collateral.serializeBigInt());
            buf.writeBytes(params.deals[i].proposal.client_collateral.serializeBigInt());

            buf.writeBytes(params.deals[i].client_signature);
        }

        return buf.data();
    }

    /// @notice deserialize PublishStorageDealsReturn struct from cbor encoded bytes coming from a market actor call
    /// @param rawResp cbor encoded response
    /// @return ret new instance of PublishStorageDealsReturn created based on parsed data
    function deserializePublishStorageDealsReturn(bytes memory rawResp) internal pure returns (MarketTypes.PublishStorageDealsReturn memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        ret.ids = new uint64[](len);

        for (uint i = 0; i < len; i++) {
            (ret.ids[i], byteIdx) = rawResp.readUInt64(byteIdx);
        }

        (ret.valid_deals, byteIdx) = rawResp.readBytes(byteIdx);

        return ret;
    }

    /// @notice serialize deal id (uint64) to cbor in order to pass as arguments to the market actor
    /// @param id deal id to serialize as cbor
    /// @return cbor serialized data as bytes
    function serializeDealID(uint64 id) internal pure returns (bytes memory) {
        uint256 capacity = Misc.getPrefixSize(uint256(id));
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.writeUInt64(id);

        return buf.data();
    }

    function deserializeMarketDealNotifyParams(bytes memory rawResp) internal pure returns (MarketTypes.MarketDealNotifyParams memory ret) {
        uint byteIdx = 0;
        uint len;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 2);

        (ret.dealProposal, byteIdx) = rawResp.readBytes(byteIdx);
        (ret.dealId, byteIdx) = rawResp.readUInt64(byteIdx);
    }

    function serializeDealProposal(MarketTypes.DealProposal memory dealProposal) internal pure returns (bytes memory) {
        uint256 capacity = 0;
        bytes memory storage_price_per_epoch = dealProposal.storage_price_per_epoch.serializeBigInt();
        bytes memory provider_collateral = dealProposal.provider_collateral.serializeBigInt();
        bytes memory client_collateral = dealProposal.client_collateral.serializeBigInt();

        capacity += Misc.getPrefixSize(11);
        capacity += Misc.getCidSize(dealProposal.piece_cid.data);
        capacity += Misc.getPrefixSize(dealProposal.piece_size);
        capacity += Misc.getBoolSize();
        capacity += Misc.getBytesSize(dealProposal.client.data);
        capacity += Misc.getBytesSize(dealProposal.provider.data);
        capacity += Misc.getBytesSize(dealProposal.label.data);
        capacity += Misc.getChainEpochSize(dealProposal.start_epoch);
        capacity += Misc.getChainEpochSize(dealProposal.end_epoch);
        capacity += Misc.getBytesSize(storage_price_per_epoch);
        capacity += Misc.getBytesSize(provider_collateral);
        capacity += Misc.getBytesSize(client_collateral);
        CBOR.CBORBuffer memory buf = CBOR.create(capacity);

        buf.startFixedArray(11);

        buf.writeCid(dealProposal.piece_cid.data);
        buf.writeUInt64(dealProposal.piece_size);
        buf.writeBool(dealProposal.verified_deal);
        buf.writeBytes(dealProposal.client.data);
        buf.writeBytes(dealProposal.provider.data);
        buf.writeDealLabel(dealProposal.label);
        buf.writeChainEpoch(dealProposal.start_epoch);
        buf.writeChainEpoch(dealProposal.end_epoch);
        buf.writeBytes(storage_price_per_epoch);
        buf.writeBytes(provider_collateral);
        buf.writeBytes(client_collateral);

        return buf.data();
    }

    function deserializeDealProposal(bytes memory rawResp) internal pure returns (MarketTypes.DealProposal memory ret) {
        uint byteIdx = 0;
        uint len;
        bytes memory tmp;

        (len, byteIdx) = rawResp.readFixedArray(byteIdx);
        assert(len == 11);

        (ret.piece_cid, byteIdx) = rawResp.readCid(byteIdx);
        (ret.piece_size, byteIdx) = rawResp.readUInt64(byteIdx);
        (ret.verified_deal, byteIdx) = rawResp.readBool(byteIdx);
        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.client = FilAddresses.fromBytes(tmp);

        (tmp, byteIdx) = rawResp.readBytes(byteIdx);
        ret.provider = FilAddresses.fromBytes(tmp);

        (ret.label, byteIdx) = rawResp.readDealLabel(byteIdx);

        (ret.start_epoch, byteIdx) = rawResp.readChainEpoch(byteIdx);
        (ret.end_epoch, byteIdx) = rawResp.readChainEpoch(byteIdx);

        bytes memory storage_price_per_epoch_bytes;
        (storage_price_per_epoch_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.storage_price_per_epoch = storage_price_per_epoch_bytes.deserializeBigInt();

        bytes memory provider_collateral_bytes;
        (provider_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.provider_collateral = provider_collateral_bytes.deserializeBigInt();

        bytes memory client_collateral_bytes;
        (client_collateral_bytes, byteIdx) = rawResp.readBytes(byteIdx);
        ret.client_collateral = client_collateral_bytes.deserializeBigInt();
    }
}

// File: @zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol

/*******************************************************************************
 *   (c) 2022 Zondax AG
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
//
// THIS CODE WAS SECURITY REVIEWED BY KUDELSKI SECURITY, BUT NOT FORMALLY AUDITED

pragma solidity ^0.8.17;








/// @title This library is a proxy to the singleton Storage Market actor (address: f05). Calling one of its methods will result in a cross-actor call being performed.
/// @author Zondax AG
library MarketAPI {
    using BytesCBOR for bytes;
    using MarketCBOR for *;
    using FilecoinCBOR for *;

    /// @notice Deposits the received value into the balance held in escrow.
    function addBalance(CommonTypes.FilAddress memory providerOrClient, uint256 value) internal {
        bytes memory raw_request = providerOrClient.serializeAddress();

        bytes memory data = Actor.callByID(MarketTypes.ActorID, MarketTypes.AddBalanceMethodNum, Misc.CBOR_CODEC, raw_request, value, false);
        if (data.length != 0) {
            revert Actor.InvalidResponseLength();
        }
    }

    /// @notice Attempt to withdraw the specified amount from the balance held in escrow.
    /// @notice If less than the specified amount is available, yields the entire available balance.
    function withdrawBalance(MarketTypes.WithdrawBalanceParams memory params) internal returns (CommonTypes.BigInt memory) {
        bytes memory raw_request = params.serializeWithdrawBalanceParams();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.WithdrawBalanceMethodNum, Misc.CBOR_CODEC, raw_request, 0, false);

        return result.deserializeBytesBigInt();
    }

    /// @notice Return the escrow balance and locked amount for an address.
    /// @return the escrow balance and locked amount for an address.
    function getBalance(CommonTypes.FilAddress memory addr) internal returns (MarketTypes.GetBalanceReturn memory) {
        bytes memory raw_request = addr.serializeAddress();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetBalanceMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeGetBalanceReturn();
    }

    /// @notice This will be available after the deal is published (whether or not is is activated) and up until some undefined period after it is terminated.
    /// @return the data commitment and size of a deal proposal.
    function getDealDataCommitment(uint64 dealID) internal returns (MarketTypes.GetDealDataCommitmentReturn memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealDataCommitmentMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeGetDealDataCommitmentReturn();
    }

    /// @notice get the client of the deal proposal.
    /// @return the client of a deal proposal.
    function getDealClient(uint64 dealID) internal returns (uint64) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealClientMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeUint64();
    }

    /// @notice get the provider of a deal proposal.
    /// @return the provider of a deal proposal.
    function getDealProvider(uint64 dealID) internal returns (uint64) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealProviderMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeUint64();
    }

    /// @notice Get the label of a deal proposal.
    /// @return the label of a deal proposal.
    function getDealLabel(uint64 dealID) internal returns (CommonTypes.DealLabel memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealLabelMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeDealLabel();
    }

    /// @notice Get the start epoch and duration(in epochs) of a deal proposal.
    /// @return the start epoch and duration (in epochs) of a deal proposal.
    function getDealTerm(uint64 dealID) internal returns (MarketTypes.GetDealTermReturn memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealTermMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeGetDealTermReturn();
    }

    /// @notice get the total price that will be paid from the client to the provider for this deal.
    /// @return the per-epoch price of a deal proposal.
    function getDealTotalPrice(uint64 dealID) internal returns (CommonTypes.BigInt memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealTotalPriceMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeBytesBigInt();
    }

    /// @notice get the client collateral requirement for a deal proposal.
    /// @return the client collateral requirement for a deal proposal.
    function getDealClientCollateral(uint64 dealID) internal returns (CommonTypes.BigInt memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealClientCollateralMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeBytesBigInt();
    }

    /// @notice get the provide collateral requirement for a deal proposal.
    /// @return the provider collateral requirement for a deal proposal.
    function getDealProviderCollateral(uint64 dealID) internal returns (CommonTypes.BigInt memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealProviderCollateralMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeBytesBigInt();
    }

    /// @notice get the verified flag for a deal proposal.
    /// @notice Note that the source of truth for verified allocations and claims is the verified registry actor.
    /// @return the verified flag for a deal proposal.
    function getDealVerified(uint64 dealID) internal returns (bool) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealVerifiedMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeBool();
    }

    /// @notice Fetches activation state for a deal.
    /// @notice This will be available from when the proposal is published until an undefined period after the deal finishes (either normally or by termination).
    /// @return USR_NOT_FOUND if the deal doesn't exist (yet), or EX_DEAL_EXPIRED if the deal has been removed from state.
    function getDealActivation(uint64 dealID) internal returns (MarketTypes.GetDealActivationReturn memory) {
        bytes memory raw_request = dealID.serializeDealID();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.GetDealActivationMethodNum, Misc.CBOR_CODEC, raw_request, 0, true);

        return result.deserializeGetDealActivationReturn();
    }

    /// @notice Publish a new set of storage deals (not yet included in a sector).
    function publishStorageDeals(MarketTypes.PublishStorageDealsParams memory params) internal returns (MarketTypes.PublishStorageDealsReturn memory) {
        bytes memory raw_request = params.serializePublishStorageDealsParams();

        bytes memory result = Actor.callByID(MarketTypes.ActorID, MarketTypes.PublishStorageDealsMethodNum, Misc.CBOR_CODEC, raw_request, 0, false);

        return result.deserializePublishStorageDealsReturn();
    }
}

// File: contracts/DealClient.sol


pragma solidity ^0.8.17;














using CBOR for CBOR.CBORBuffer;

struct RequestId {
    bytes32 requestId;
    bool valid;
}

struct RequestIdx {
    uint256 idx;
    bool valid;
}

struct ProviderSet {
    bytes provider;
    bool valid;
}

// User request for this contract to make a deal. This structure is modelled after Filecoin's Deal
// Proposal, but leaves out the provider, since any provider can pick up a deal broadcast by this
// contract.
struct DealRequest {
    bytes piece_cid;
    uint64 piece_size;
    bool verified_deal;
    string label;
    int64 start_epoch;
    int64 end_epoch;
    uint256 storage_price_per_epoch;
    uint256 provider_collateral;
    uint256 client_collateral;
    uint64 extra_params_version;
    ExtraParamsV1 extra_params;
}

// Extra parameters associated with the deal request. These are off-protocol flags that
// the storage provider will need.
struct ExtraParamsV1 {
    string location_ref;
    uint64 car_size;
    bool skip_ipni_announce;
    bool remove_unsealed_copy;
}

function serializeExtraParamsV1(ExtraParamsV1 memory params) pure returns (bytes memory) {
    CBOR.CBORBuffer memory buf = CBOR.create(64);
    buf.startFixedArray(4);
    buf.writeString(params.location_ref);
    buf.writeUInt64(params.car_size);
    buf.writeBool(params.skip_ipni_announce);
    buf.writeBool(params.remove_unsealed_copy);
    return buf.data();
}

contract DealClient {
    using AccountCBOR for *;
    using MarketCBOR for *;

    uint64 public constant AUTHENTICATE_MESSAGE_METHOD_NUM = 2643134072;
    uint64 public constant DATACAP_RECEIVER_HOOK_METHOD_NUM = 3726118371;
    uint64 public constant MARKET_NOTIFY_DEAL_METHOD_NUM = 4186741094;
    address public constant MARKET_ACTOR_ETH_ADDRESS =
        address(0xff00000000000000000000000000000000000005);
    address public constant DATACAP_ACTOR_ETH_ADDRESS =
        address(0xfF00000000000000000000000000000000000007);

    enum Status {
        None,
        RequestSubmitted,
        DealPublished,
        DealActivated,
        DealTerminated
    }

    mapping(bytes32 => RequestIdx) public dealRequestIdx; // contract deal id -> deal index
    DealRequest[] public dealRequests;

    mapping(bytes => RequestId) public pieceRequests; // commP -> dealProposalID
    mapping(bytes => ProviderSet) public pieceProviders; // commP -> provider
    mapping(bytes => uint64) public pieceDeals; // commP -> deal ID
    mapping(bytes => Status) public pieceStatus; // commP -> Status

    event ReceivedDataCap(string received);
    event DealProposalCreate(bytes32 indexed id, uint64 size, bool indexed verified, uint256 price);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function getProviderSet(bytes calldata cid) public view returns (ProviderSet memory) {
        return pieceProviders[cid];
    }

    function getPieceStatus(bytes calldata cid) public view returns (Status){
        return pieceStatus[cid];
    }

    function getDealId(bytes calldata cid) public view returns(uint64) {
        return pieceDeals[cid];
    }

    function getProposalIdSet(bytes calldata cid) public view returns (RequestId memory) {
        return pieceRequests[cid];
    }

    function dealsLength() public view returns (uint256) {
        return dealRequests.length;
    }

    function getDealByIndex(uint256 index) public view returns (DealRequest memory) {
        return dealRequests[index];
    }

    function makeDealProposal(DealRequest calldata deal) public returns (bytes32) {
        require(msg.sender == owner);

        if (
            pieceStatus[deal.piece_cid] == Status.DealPublished ||
            pieceStatus[deal.piece_cid] == Status.DealActivated
        ) {
            revert("deal with this pieceCid already published");
        }

        uint256 index = dealRequests.length;
        dealRequests.push(deal);

        // creates a unique ID for the deal proposal -- there are many ways to do this
        bytes32 id = keccak256(abi.encodePacked(block.timestamp, msg.sender, index));
        dealRequestIdx[id] = RequestIdx(index, true);

        pieceRequests[deal.piece_cid] = RequestId(id, true);
        pieceStatus[deal.piece_cid] = Status.RequestSubmitted;

        // writes the proposal metadata to the event log
        emit DealProposalCreate(
            id,
            deal.piece_size,
            deal.verified_deal,
            deal.storage_price_per_epoch
        );

        return id;
    }

    // helper function to get deal request based from id
    function getDealRequest(bytes32 requestId) internal view returns (DealRequest memory) {
        RequestIdx memory ri = dealRequestIdx[requestId];
        require(ri.valid, "proposalId not available");
        return dealRequests[ri.idx];
    }

    // Returns a CBOR-encoded DealProposal.
    function getDealProposal(bytes32 proposalId) public view returns (bytes memory) {
        DealRequest memory deal = getDealRequest(proposalId);

        MarketTypes.DealProposal memory ret;
        ret.piece_cid = CommonTypes.Cid(deal.piece_cid);
        ret.piece_size = deal.piece_size;
        ret.verified_deal = deal.verified_deal;
        ret.client = FilAddresses.fromEthAddress(address(this));
        // Set a dummy provider. The provider that picks up this deal will need to set its own address.
        ret.provider = FilAddresses.fromActorID(0);
        ret.label = CommonTypes.DealLabel(bytes(deal.label), true);
        ret.start_epoch = CommonTypes.ChainEpoch.wrap(deal.start_epoch);
        ret.end_epoch = CommonTypes.ChainEpoch.wrap(deal.end_epoch);
        ret.storage_price_per_epoch = BigInts.fromUint256(deal.storage_price_per_epoch);
        ret.provider_collateral = BigInts.fromUint256(deal.provider_collateral);
        ret.client_collateral = BigInts.fromUint256(deal.client_collateral);

        return MarketCBOR.serializeDealProposal(ret);
    }

    function getExtraParams(bytes32 proposalId) public view returns (bytes memory extra_params) {
        DealRequest memory deal = getDealRequest(proposalId);
        return serializeExtraParamsV1(deal.extra_params);
    }

    // authenticateMessage is the callback from the market actor into the contract
    // as part of PublishStorageDeals. This message holds the deal proposal from the
    // miner, which needs to be validated by the contract in accordance with the
    // deal requests made and the contract's own policies
    // @params - cbor byte array of AccountTypes.AuthenticateMessageParams
    function authenticateMessage(bytes memory params) internal view {
        require(msg.sender == MARKET_ACTOR_ETH_ADDRESS, "msg.sender needs to be market actor f05");

        AccountTypes.AuthenticateMessageParams memory amp = params
            .deserializeAuthenticateMessageParams();
        MarketTypes.DealProposal memory proposal = MarketCBOR.deserializeDealProposal(amp.message);

        bytes memory pieceCid = proposal.piece_cid.data;
        require(pieceRequests[pieceCid].valid, "piece cid must be added before authorizing");
        require(
            !pieceProviders[pieceCid].valid,
            "deal failed policy check: provider already claimed this cid"
        );

        DealRequest memory req = getDealRequest(pieceRequests[pieceCid].requestId);
        require(proposal.verified_deal == req.verified_deal, "verified_deal param mismatch");
        (uint256 proposalStoragePricePerEpoch, bool storagePriceConverted) = BigInts.toUint256(
            proposal.storage_price_per_epoch
        );
        (uint256 proposalClientCollateral, bool collateralConverted) = BigInts.toUint256(
            proposal.storage_price_per_epoch
        );
        require(
            storagePriceConverted && collateralConverted,
            "Issues converting uint256 to BigInt, may not have accurate values"
        );
        require(
            proposalStoragePricePerEpoch <= req.storage_price_per_epoch,
            "storage price greater than request amount"
        );
        require(
            proposalClientCollateral <= req.client_collateral,
            "client collateral greater than request amount"
        );
    }

    // dealNotify is the callback from the market actor into the contract at the end
    // of PublishStorageDeals. This message holds the previously approved deal proposal
    // and the associated dealID. The dealID is stored as part of the contract state
    // and the completion of this call marks the success of PublishStorageDeals
    // @params - cbor byte array of MarketDealNotifyParams
    function dealNotify(bytes memory params) internal {
        require(msg.sender == MARKET_ACTOR_ETH_ADDRESS, "msg.sender needs to be market actor f05");

        MarketTypes.MarketDealNotifyParams memory mdnp = MarketCBOR
            .deserializeMarketDealNotifyParams(params);
        MarketTypes.DealProposal memory proposal = MarketCBOR.deserializeDealProposal(
            mdnp.dealProposal
        );

        // These checks prevent race conditions between the authenticateMessage and
        // marketDealNotify calls where someone could have 2 of the same deal proposals
        // within the same PSD msg, which would then get validated by authenticateMessage
        // However, only one of those deals should be allowed
        require(
            pieceRequests[proposal.piece_cid.data].valid,
            "piece cid must be added before authorizing"
        );
        require(
            !pieceProviders[proposal.piece_cid.data].valid,
            "deal failed policy check: provider already claimed this cid"
        );

        pieceProviders[proposal.piece_cid.data] = ProviderSet(proposal.provider.data, true);
        pieceDeals[proposal.piece_cid.data] = mdnp.dealId;
        pieceStatus[proposal.piece_cid.data] = Status.DealPublished;
    }

    // This function can be called/smartly polled to retrieve the deal activation status
    // associated with provided pieceCid and update the contract state based on that
    // info
    // @pieceCid - byte representation of pieceCid
    function updateActivationStatus(bytes memory pieceCid) public {
        require(pieceDeals[pieceCid] > 0, "no deal published for this piece cid");

        MarketTypes.GetDealActivationReturn memory ret = MarketAPI.getDealActivation(
            pieceDeals[pieceCid]
        );
        if (CommonTypes.ChainEpoch.unwrap(ret.terminated) > 0) {
            pieceStatus[pieceCid] = Status.DealTerminated;
        } else if (CommonTypes.ChainEpoch.unwrap(ret.activated) > 0) {
            pieceStatus[pieceCid] = Status.DealActivated;
        }
    }

    // addBalance funds the builtin storage market actor's escrow
    // with funds from the contract's own balance
    // @value - amount to be added in escrow in attoFIL
    function addBalance(uint256 value) public {
        require(msg.sender == owner);
        MarketAPI.addBalance(FilAddresses.fromEthAddress(address(this)), value);
    }

    // This function attempts to withdraw the specified amount from the contract addr's escrow balance
    // If less than the given amount is available, the full escrow balance is withdrawn
    // @client - Eth address where the balance is withdrawn to. This can be the contract address or an external address
    // @value - amount to be withdrawn in escrow in attoFIL
    function withdrawBalance(address client, uint256 value) public returns (uint) {
        require(msg.sender == owner);

        MarketTypes.WithdrawBalanceParams memory params = MarketTypes.WithdrawBalanceParams(
            FilAddresses.fromEthAddress(client),
            BigInts.fromUint256(value)
        );
        CommonTypes.BigInt memory ret = MarketAPI.withdrawBalance(params);

        (uint256 withdrawBalanceAmount, bool withdrawBalanceConverted) = BigInts.toUint256(ret);
        require(
            withdrawBalanceConverted,
            "Problems converting withdraw balance into Big Int, may cause an overflow"
        );

        return withdrawBalanceAmount;
    }

    function receiveDataCap(bytes memory params) internal {
        require(
            msg.sender == DATACAP_ACTOR_ETH_ADDRESS,
            "msg.sender needs to be datacap actor f07"
        );
        emit ReceivedDataCap("DataCap Received!");
        // Add get datacap balance api and store datacap amount
    }

    // handle_filecoin_method is the universal entry point for any evm based
    // actor for a call coming from a builtin filecoin actor
    // @method - FRC42 method number for the specific method hook
    // @params - CBOR encoded byte array params
    function handle_filecoin_method(
        uint64 method,
        uint64,
        bytes memory params
    ) public returns (uint32, uint64, bytes memory) {
        bytes memory ret;
        uint64 codec;
        // dispatch methods
        if (method == AUTHENTICATE_MESSAGE_METHOD_NUM) {
            authenticateMessage(params);
            // If we haven't reverted, we should return a CBOR true to indicate that verification passed.
            CBOR.CBORBuffer memory buf = CBOR.create(1);
            buf.writeBool(true);
            ret = buf.data();
            codec = Misc.CBOR_CODEC;
        } else if (method == MARKET_NOTIFY_DEAL_METHOD_NUM) {
            dealNotify(params);
        } else if (method == DATACAP_RECEIVER_HOOK_METHOD_NUM) {
            receiveDataCap(params);
        } else {
            revert("the filecoin method that was called is not handled");
        }
        return (0, codec, ret);
    }
}
