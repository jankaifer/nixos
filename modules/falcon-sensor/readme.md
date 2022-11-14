# Falcon sensor setup

This one is a bit tricky. I used these configs as an inspisation:
- https://gist.github.com/klDen/c90d9798828e31fecbb603f85e27f4f1
- https://gist.github.com/spinus/be0ca03def0c856ada86b16d1727d09d

The only thing that is left to do is to seg my correct `CID`. You can do it by finding the correct executable with:

```bash
$ echo `find /nix/store -name "falconctl" 2>/dev/null`
/nix/store/xsf54i2hlfg6g4y1cmdf0h5jx8gf0jrq-falcon-sensor/opt/CrowdStrike/falconctl
/nix/store/nxn0yj6xazifcnnlw9mcxi4mgxfqc237-falcon/opt/CrowdStrike/falconctl
/nix/store/pjv24q2zjsjsm6vx23g66a7xp74f2vyj-falcon-sensor/opt/CrowdStrike/falconctl
```
Pich one of them and use it to set the CID:

```bash
$ sudo /nix/store/xsf54i2hlfg6g4y1cmdf0h5jx8gf0jrq-falcon-sensor/opt/CrowdStrike/falconctl -s -f --cid='YOUR-CID'
```

You can check the status with `systemctl status falcon-sensor`, it should be running now.