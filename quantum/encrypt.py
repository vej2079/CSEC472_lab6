import sys
import qsharp
from Lab6 import T26_BB84Protocol_Reference
from Lab6 import T32_BB84ProtocolWithEavesdropper_Reference

def VITM():
    keyHermione, keyHarry = T32_BB84ProtocolWithEavesdropper_Reference.simulate()
    # toEncrypt = "hello from the quantum world"
    # encrypted = ""
    # for char in toEncrypt:
    #     encrypted = encrypted + str(ord(char) ^ keyHermione)
    # length = int(len(encrypted)/len(toEncrypt))
    # print("Encrypted: " + encrypted)
    # decrypted = ""
    # values = [encrypted[i:i+length] for i in range(0, len(encrypted), length)]
    # for val in values:
    #     decrypted = decrypted + chr(int(val) ^ keyHarry)
    # print("Decrypted: " + decrypted)

def default():
    keyHermione, keyHarry = T26_BB84Protocol_Reference.simulate()
    toEncrypt = "hello from the quantum world"
    encrypted = ""
    for char in toEncrypt:
        encrypted = encrypted + str(ord(char) ^ keyHermione)
    length = int(len(encrypted)/len(toEncrypt))
    print("Encrypted: " + encrypted)
    decrypted = ""
    values = [encrypted[i:i+length] for i in range(0, len(encrypted), length)]
    for val in values:
        decrypted = decrypted + chr(int(val) ^ keyHarry)
    print("Decrypted: " + decrypted)

if __name__ == '__main__':
    default()
    #VITM()
