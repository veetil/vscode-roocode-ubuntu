To run **GUI Emacs** on your AWS EC2 Ubuntu instance and view it on your Mac, you'll want to use **X11 forwarding**. Here’s a detailed step-by-step guide to tunnel GUI apps like Emacs from EC2 to macOS:

---

## 1. Install & Launch XQuartz on macOS (Your X11 Server)

macOS does not include an X11 server by default. You’ll need **XQuartz**:

* Download and install XQuartz from the official source.
* After installation, **open XQuartz.app** manually before using SSH ([Ask Different][1], [UCSB Engineering][2]).

This sets up your Mac to act as the X11 server for forwarded GUI windows.

---

## 2. Configure SSH on the Ubuntu EC2 Server

On your EC2 Ubuntu instance, ensure SSH is configured to allow X11 forwarding:

1. Connect (temporarily via SSH or console) and edit:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Ensure these lines are present (and uncommented):

   ```
   X11Forwarding yes
   X11UseLocalhost yes
   ```
3. Install `xauth`, which SSH uses for secure X11 authentication:

   ```bash
   sudo apt update
   sudo apt install xauth
   ```
4. Restart the SSH service:

   ```bash
   sudo systemctl restart sshd
   ```

   ([Unix & Linux Stack Exchange][3], [Some Natalie’s corner of the internet][4])

---

## 3. Connect via SSH with X11 Forwarding from Your Mac

From your Mac Terminal (or iTerm2), run:

```bash
ssh -Y -i /path/to/your-key.pem ubuntu@<ec2-public-dns>
```

* `-Y` enables trusted X11 forwarding (more reliable than `-X` in some cases).
* Ensure XQuartz is already running before you connect.
* You can also set `ForwardX11 yes` in your `~/.ssh/config` for convenience ([Unix & Linux Stack Exchange][3], [UCSB Engineering][2]).

To verify forwarding is working:

```bash
echo $DISPLAY
```

Expect an output like `localhost:10.0`. If it’s empty, forwarding isn’t active.

---

## 4. Run Emacs with GUI Support

Back on the EC2 shell, start Emacs:

```bash
emacs &
```

This should open a GUI Emacs window on your Mac, rendered via XQuartz.

If it fails (e.g. crashes, or no GUI), possible reasons:

* **Emacs not built with X support.**
  Check within Emacs: evaluate `(featurep 'x)` in `*scratch*` → press `Ctrl+J`. If it returns `nil`, your Emacs lacks X support ([Unix & Linux Stack Exchange][5]).
* In that case, install or compile X-enabled Emacs:

  ```bash
  sudo apt install emacs
  # or emacs-gtk or emacs-x11 variant depending on Ubuntu version
  ```

---

## 5. Alternative: Tunnel macOS GUI via VNC

If you need a **full remote macOS desktop**, you can run a GUI on an EC2 **macOS** instance (rather than Ubuntu) and connect via VNC:

* Enable Screen Sharing on the macOS EC2 instance:

  ```bash
  sudo /usr/bin/dscl . -passwd /Users/ec2-user
  sudo launchctl enable system/com.apple.screensharing
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
  ```
* Create an SSH tunnel on your Mac:

  ```bash
  ssh -i keypair.pem -L 5900:localhost:5900 ec2-user@<mac-ec2-dns>
  ```
* Keep this tunnel open, then connect via a VNC client to `localhost:5900` with the `ec2-user` password ([AWS Documentation][6], [Repost][7], [The Linux Code][8]).

This gives you the **entire macOS desktop GUI**, not just individual app windows.

---

### ✅ Summary Table

| Use Case                          | Steps Summary                                                                                                                              |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Run Emacs GUI from Ubuntu EC2** | 1. Install & launch XQuartz on Mac<br>2. Enable `X11Forwarding` and install `xauth` on EC2<br>3. SSH with `ssh -Y ...`<br>4. Run `emacs &` |
| **Full macOS desktop on EC2**     | Use Mac EC2 instance + enable screen sharing<br>Tunnel port 5900 via SSH<br>Connect with VNC client                                        |

---

Let me know which approach you'd like to pursue or if you'd like help installing the GUI-enabled Emacs package on your Ubuntu EC2.

[1]: https://apple.stackexchange.com/questions/421564/cant-get-x11-to-work-in-macos-big-sur?utm_source=chatgpt.com "terminal - Can't get X11 to work in macOS Big Sur - Ask Different"
[2]: https://ucsb-engr.atlassian.net/wiki/spaces/EPK/pages/573603972/How%2Bto%2Bdo%2BX11%2BForwarding%2Bon%2Ba%2BMac?utm_source=chatgpt.com "How to do X11 Forwarding on a Mac"
[3]: https://unix.stackexchange.com/questions/12755/how-to-forward-x-over-ssh-to-run-graphics-applications-remotely?utm_source=chatgpt.com "How to forward X over SSH to run graphics applications remotely?"
[4]: https://some-natalie.dev/blog/ssh-x11-forwarding/?utm_source=chatgpt.com "A quick and dirty guide to X11 forwarding over SSH"
[5]: https://unix.stackexchange.com/questions/244954/emacs-x11-forwarding-does-not-work-but-xclock-does?utm_source=chatgpt.com "Emacs X11 Forwarding does not work but xclock does"
[6]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-to-mac-instance.html?utm_source=chatgpt.com "Connect to your Mac instance using SSH or a GUI"
[7]: https://repost.aws/knowledge-center/ec2-mac-instance-gui-access?utm_source=chatgpt.com "Access an EC2 macOS instance through a GUI | AWS re:Post"
[8]: https://thelinuxcode.com/enable-gui-with-mac-os-ec2-instance-ssh-connection/?utm_source=chatgpt.com "Unlocking the Full Power of macOS on EC2 with GUI Access"
