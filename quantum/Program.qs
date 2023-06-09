// namespace quantum {

//     open Microsoft.Quantum.Canon;
//     open Microsoft.Quantum.Intrinsic;
    
//     @EntryPoint()
//     operation SayHello() : Unit {
//         Message("Hello quantum world!");
//     }
// }

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.KeyDistribution {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Bitwise;
    
    //////////////////////////////////////////////////////////////////
    // Part I. Preparation
    //////////////////////////////////////////////////////////////////
    
    // Task 1.1. Diagonal polarization
    operation DiagonalBasis_Reference (qs : Qubit[]) : Unit is Adj {
        ApplyToEachA(H, qs);
    }


    // Task 1.2. Equal superposition.
    operation EqualSuperposition_Reference (q : Qubit) : Unit {
        // The easiest way to do this is to convert the state of the qubit to |+⟩
        H(q);
        // Other possible solutions include X(q); H(q); to prepare |-⟩ state,
        // and anything that adds any relative phase to one of the states.
    }

    //////////////////////////////////////////////////////////////////
    // Part II. BB84 Protocol
    //////////////////////////////////////////////////////////////////

    // Task 2.1. Generate random array
    operation RandomArray_Reference (N : Int) : Bool[] {
        mutable array = [false, size = N];

        for i in 0 .. N - 1 {
            set array w/= i <- DrawRandomBool(0.5);
        }

        return array;
    }


    // Task 2.2. Prepare Hermione's qubits
    operation PrepareHermionesQubits_Reference (qs : Qubit[], bases : Bool[], bits : Bool[]) : Unit is Adj {
        for i in 0 .. Length(qs) - 1 {
            if bits[i] {
                X(qs[i]);
            }
            if bases[i] {
                H(qs[i]);
            }
        }
    }


    // Task 2.3. Measure Harry's qubits
    operation MeasureHarrysQubits_Reference (qs : Qubit[], bases : Bool[]) : Bool[] {
        for i in 0 .. Length(qs) - 1 { // Measure([PauliZ], [q]); // where PauliZ is the standard/horizontal basis and q is a qubit ptr
            if bases[i] {
                H(qs[i]);
            }
        }
        return ResultArrayAsBoolArray(MultiM(qs));
    }


    // Task 2.4. Generate the shared key!
    function GenerateSharedKey_Reference (basesHermione : Bool[], basesHarry : Bool[], measurementsHarry : Bool[]) : Bool[] {
        // If Hermione and Harry used the same basis, they will have the same value of the bit.
        // The shared key consists of those bits.
        mutable key = [];
        for (a, b, bit) in Zipped3(basesHermione, basesHarry, measurementsHarry) {
            if a == b {
                set key += [bit];
            }
        }
        return key;
    }


    // Task 2.5. Check if error rate was low enough
    function CheckKeysMatch_Reference (keyHermione : Bool[], keyHarry : Bool[], errorRate : Int) : Bool {
        let N = Length(keyHermione);
        mutable mismatchCount = 0;
        for i in 0 .. N - 1 {
            if keyHermione[i] != keyHarry[i] {
                set mismatchCount += 1;
            }
        }

        return IntAsDouble(mismatchCount) / IntAsDouble(N) <= IntAsDouble(errorRate) / 100.0;
    }

    @EntryPoint()
    // Task 2.6. Putting it all together 
    operation T26_BB84Protocol_Reference () : Unit {
        let threshold = 1;

        use qs = Qubit[20];
        // 1. Choose random basis and bits to encode
        let basesHermione = RandomArray_Reference(Length(qs));
        let bitsHermione = RandomArray_Reference(Length(qs));
        
        // 2. Hermione prepares her qubits
        PrepareHermionesQubits_Reference(qs, basesHermione, bitsHermione);
        
        // 3. Harry chooses random basis to measure in
        let basesHarry = RandomArray_Reference(Length(qs));

        // 4. Harry measures Hermione's qubits
        let bitsHarry = MeasureHarrysQubits_Reference(qs, basesHarry);

        // 5. Generate shared key
        let keyHermione = GenerateSharedKey_Reference(basesHermione, basesHarry, bitsHermione);
        let keyHarry = GenerateSharedKey_Reference(basesHermione, basesHarry, bitsHarry);

        // 6. Ensure at least the minimum percentage of bits match
        if CheckKeysMatch_Reference(keyHermione, keyHarry, threshold) {
            Message($"Successfully generated keys {keyHermione}/{keyHarry}");
        }
        let toEncrypt = "hello from the quantum world!";
        let encrypted = Xor(BoolArrayAsInt(keyHermione), toEncrypt);
        let decrypted = Xor(encrypted, BoolArrayAsInt(keyHarry));
        Message($"Encrypted: {encrypted}");
        Message($"Decrypted: {decrypted}");
    }


    //////////////////////////////////////////////////////////////////
    // Part III. Eavesdropping
    //////////////////////////////////////////////////////////////////

    // Task 3.1. Eavesdrop!
    operation Eavesdrop_Reference (q : Qubit, basis : Bool) : Bool {
        return ResultAsBool(Measure([basis ? PauliX | PauliZ], [q]));
    }

    // @EntryPoint()
    // Task 3.2. Catch the eavesdropper
    operation T32_BB84ProtocolWithEavesdropper_Reference () : Unit {
        let threshold = 1;

        use qs = Qubit[20];
        // 1. Choose random basis and bits to encode
        let basesHermione = RandomArray_Reference(Length(qs));
        let bitsHermione = RandomArray_Reference(Length(qs));
        
        // 2. Hermione prepares her qubits
        PrepareHermionesQubits_Reference(qs, basesHermione, bitsHermione);
        
        // Voldemort eavesdrops on all qubits, guessing the basis at random
        for q in qs {
            let n = Eavesdrop_Reference(q, DrawRandomBool(0.5));
        }

        // 3. Harry chooses random basis to measure in
        let basesHarry = RandomArray_Reference(Length(qs));

        // 4. Harry measures Hermione's qubits'
        let bitsHarry = MeasureHarrysQubits_Reference(qs, basesHarry);

        // 5. Generate shared key
        let keyHermione = GenerateSharedKey_Reference(basesHermione, basesHarry, bitsHermione);
        let keyHarry = GenerateSharedKey_Reference(basesHermione, basesHarry, bitsHarry);

        // 6. Ensure at least the minimum percentage of bits match
        if CheckKeysMatch_Reference(keyHermione, keyHarry, threshold) {
            Message($"Successfully generated keys {keyHermione}/{keyHarry}");
        } else {
            Message($"Hermione's basis: {basesHermione}");
            Message($"Harrys's basis: {basesHarry}");
            Message($"Hermione's measurements: {bitsHermione}");
            Message($"Harry's measurements: {bitsHarry}");
            Message($"Caught an eavesdropper, Expelliarmis!"); // discarding the keys {keyHermione}/{keyHarry}");
        }
    }

    
}

