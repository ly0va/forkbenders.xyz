## Homework
- **ECB byte-at-a-time** task is on port [31818](http://forkbenders.xyz:31818)
- **Padding Oracle** task is on port [31337](http://forkbenders.xyz:31337)

## Wall of Heros
Bender | ECB | Padding Oracle 
--- | :---: | :---:
Сидор | ✔️ | ✔️
Оленка | ✔️ | ✔️
Маша | ✔️ | ✔️ 
Боровой | ✔️ |
Тимофей | ✔️ |
Роик | | ✔️
Юра | ✔️ |
Ищенко | ✔️ |

## Solutions

### ECB byte-at-a-time

```python
#!/usr/bin/python2

import requests as r
import sys

URL = "http://forkbenders.xyz:31818?data="
data = 'a'*15
flag = ''
b = 32

while True:
    block = r.get(URL+data).text
    for i in range(0x20, 0x80):
        if chr(i) in '&#': continue
        resp = r.get(URL+data+flag+chr(i)).text
        sys.stdout.write('\r'+flag+chr(i))
        sys.stdout.flush()
        if block[:b] == resp[:b]:
            data = data[1:]
            flag += chr(i)
            if len(flag) % 16 == 0:
                b += 32
                data = 'a'*15
            break
    else:
        print "\r" + flag + " \nDONE"
        break
```

### Padding Oracle
```python3
#!/usr/bin/python3

import requests
import sys

URL = "http://forkbenders.xyz:31337/"
n = 16

def query(iv, ct):
    return requests.get(URL + f'?iv={iv.hex()}&ct={ct.hex()}').text.strip()

def bust(iv, ct, i):
    orig_byte = iv[i]
    for byte in range(1, 0x100):
        iv[i] = orig_byte ^ byte
        response = query(iv, ct)
        if response == 'Decryption successful':
            iv[i] = orig_byte
            return byte
    return 0

iv, ct = requests.get(URL).text.strip().splitlines()
data = iv[4:] + ct[4:]
blocks = [bytearray.fromhex(data[i:i+32]) for i in range(0, len(data), 32)]
message = b''

for b in range(len(blocks)-2, -1, -1):
    iv, ct = blocks[b].copy(), blocks[b+1].copy()
    for i in range(n-1, -1, -1):
        x = bust(iv, ct, i)
        message = (x ^ (n-i)).to_bytes(1, 'big') + message
        sys.stdout.write('\r'+str(message))
        sys.stdout.flush()
        for j in range(i, n):
            iv[j] = blocks[b][j] ^ message[j-i] ^ (n-i+1)

print("\nDONE")
```

