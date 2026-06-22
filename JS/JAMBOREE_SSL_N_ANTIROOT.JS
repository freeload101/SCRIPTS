/*
20260521: !!!!!!!!!!!!!!!!!!!!! NOTICE IF YOU EDIT THE FILE WHILE FRIDA HAS IT OPEN IS RELOADS IT AND WILL SOMETIMES FIX SSL DEPINNING !!!!!!!!!!!!!!!!!!!!!!!!
20251205: AI fixed okhttp3 depinning like a BOSS

Original author: Daniele Linguaglossa
28/07/2021 -    Edited by Simone Quatrini
                Code amended to correctly run on the latest frida version
        		Added controls to exclude Magisk Manager
*/
Java.perform(function() {
    console.log("[AUABF] Script starting...");
 
    // ─── ROOT DETECTION BYPASS ───────────────────────────────────────────────

    var File = Java.use("java.io.File");
    File.exists.implementation = function() {
        var path = this.getAbsolutePath();
        var dangerous_paths = [
            "/su", "/system/bin/su", "/system/xbin/su", "/sbin/su",
            "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
            "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su",
            "/system/app/Superuser.apk", "/system/etc/init.d/99SuperSUDaemon",
            "/dev/com.koushikdutta.superuser.daemon/", "/system/xbin/daemonsu",
            "com.koushikdutta.superuser", "com.thirdparty.superuser",
            "eu.chainfire.supersu", "com.noshufou.android.su"
        ];
        for (var i = 0; i < dangerous_paths.length; i++) {
            if (path.indexOf(dangerous_paths[i]) != -1) {
                console.log("[BYPASS-ROOT] File.exists(): " + path + " -> false");
                return false;
            }
        } 
        return this.exists();
    };

    var Runtime = Java.use("java.lang.Runtime");
    var ProcessBuilder = Java.use("java.lang.ProcessBuilder");
    var Process = Java.use("java.lang.Process");

    function createFakeProcess() {
        var ByteArrayInputStream  = Java.use("java.io.ByteArrayInputStream");
        var ByteArrayOutputStream = Java.use("java.io.ByteArrayOutputStream");
        var fakeProcess = Process.$new();
        fakeProcess.getInputStream.implementation  = function() { return ByteArrayInputStream.$new([]); };
        fakeProcess.getOutputStream.implementation = function() { return ByteArrayOutputStream.$new(); };
        fakeProcess.getErrorStream.implementation  = function() { return ByteArrayInputStream.$new([]); };
        fakeProcess.waitFor.implementation         = function() { return 0; };
        fakeProcess.exitValue.implementation       = function() { return 0; };
        fakeProcess.destroy.implementation         = function() {};
        return fakeProcess;
    }

    Runtime.exec.overload('java.lang.String').implementation = function(cmd) {
        if (cmd.indexOf("su") != -1 || cmd.indexOf("which") != -1) {
            console.log("[BYPASS-ROOT] Runtime.exec blocked: " + cmd);
            return createFakeProcess();
        }
        return this.exec(cmd);
    };
    Runtime.exec.overload('[Ljava.lang.String;').implementation = function(cmds) {
        var cmd = cmds.join(" ");
        if (cmd.indexOf("su") != -1 || cmd.indexOf("which") != -1) {
            console.log("[BYPASS-ROOT] Runtime.exec[] blocked: " + cmd);
            return createFakeProcess();
        }
        return this.exec(cmds);
    };
    Runtime.exec.overload('java.lang.String', '[Ljava.lang.String;').implementation = function(cmd, env) {
        if (cmd.indexOf("su") != -1 || cmd.indexOf("which") != -1) {
            console.log("[BYPASS-ROOT] Runtime.exec+env blocked: " + cmd);
            return createFakeProcess();
        }
        return this.exec(cmd, env);
    };
    Runtime.exec.overload('[Ljava.lang.String;', '[Ljava.lang.String;').implementation = function(cmds, env) {
        var cmd = cmds.join(" ");
        if (cmd.indexOf("su") != -1 || cmd.indexOf("which") != -1) {
            console.log("[BYPASS-ROOT] Runtime.exec[]+env blocked: " + cmd);
            return createFakeProcess();
        }
        return this.exec(cmds, env);
    };

    ProcessBuilder.start.implementation = function() {
        var cmd = this.command().toString();
        if (cmd.indexOf("su") != -1) {
            console.log("[BYPASS-ROOT] ProcessBuilder blocked: " + cmd);
            return createFakeProcess();
        }
        return this.start();
    };

    var Build = Java.use("android.os.Build");
    Build.TAGS.value = "release-keys";

    try {
        var SystemProperties = Java.use("android.os.SystemProperties");
        SystemProperties.get.overload('java.lang.String').implementation = function(key) {
            if (key == "ro.debuggable") return "0";
            if (key == "ro.secure")     return "1";
            if (key == "ro.build.tags") return "release-keys";
            return this.get(key);
        };
    } catch(e) { console.log("[ERROR] SystemProperties hook failed: " + e); }

    try {
        var PackageManager = Java.use("android.app.ApplicationPackageManager");
        PackageManager.getPackageInfo.overload('java.lang.String', 'int').implementation = function(pkg, flags) {
            var dangerous_packages = [
                "com.koushikdutta.superuser", "com.thirdparty.superuser",
                "eu.chainfire.supersu", "com.noshufou.android.su",
                "com.zachspong.temprootremovejb", "com.ramdroid.appquarantine",
                "com.koushikdutta.rommanager", "com.koushikdutta.rommanager.license",
                "com.dimonvideo.luckypatcher", "com.chelpus.lackypatch",
                "com.ramdroid.appquarantinepro"
            ];
            if (dangerous_packages.indexOf(pkg) != -1) {
                console.log("[BYPASS-ROOT] Package hidden: " + pkg);
                throw Java.use("android.content.pm.PackageManager$NameNotFoundException").$new(pkg);
            }
            return this.getPackageInfo(pkg, flags);
        };
    } catch(e) { console.log("[ERROR] PackageManager hook failed: " + e); }

    try {
        var UnixFileSystem = Java.use("java.io.UnixFileSystem");
        UnixFileSystem.checkAccess.implementation = function(file, access) {
            var path = file.toString();
            var dangerous_paths = [
                "/su", "/system/bin/su", "/system/xbin/su", "/sbin/su",
                "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
                "/system/bin/failsafe/su", "/data/local/su", "/su/bin/su",
                "/system/app/Superuser.apk", "/vendor/bin/su", "/cache/su", "/data/su"
            ];
            for (var i = 0; i < dangerous_paths.length; i++) {
                if (path.indexOf(dangerous_paths[i]) != -1) {
                    console.log("[BYPASS-ROOT] UnixFileSystem.checkAccess denied: " + path);
                    return false;
                }
            }
            return this.checkAccess(file, access);
        };
    } catch(e) { console.log("[ERROR] UnixFileSystem hook failed: " + e); }

    // ─── SSL / CERTIFICATE PINNING BYPASS ───────────────────────────────────

    // 1. Conscrypt TrustManagerImpl
    try {
        var TrustManagerImpl = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl.verifyChain.implementation = function(untrustedChain, trustAnchorChain, host, clientAuth, ocspData, tlsSctData) {
            console.log('[BYPASS-SSL] TrustManagerImpl.verifyChain bypassed for: ' + host);
            return untrustedChain;
        };
    } catch(e) { console.log('[ERROR] TrustManagerImpl.verifyChain hook failed: ' + e); }

    try {
        var TrustManagerImpl2 = Java.use('com.android.org.conscrypt.TrustManagerImpl');
        TrustManagerImpl2.checkTrustedRecursive.implementation = function(certs, host, clientAuth, untrustedChain, trustAnchorChain, used) {
            console.log('[BYPASS-SSL] TrustManagerImpl.checkTrustedRecursive bypassed for: ' + host);
            return Java.use('java.util.ArrayList').$new();
        };
    } catch(e) { console.log('[ERROR] TrustManagerImpl.checkTrustedRecursive hook failed: ' + e); }

    // 2. OkHttp3 CertificatePinner — all overloads
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List')
            .implementation = function(hostname, certs) {
                console.log('[BYPASS-SSL] OkHttp3 CertificatePinner.check(List) bypassed for: ' + hostname);
            };
    } catch(e) { console.log('[ERROR] OkHttp3 CertificatePinner.check(List) failed: ' + e); }

    try {
        var CertificatePinner2 = Java.use('okhttp3.CertificatePinner');
        CertificatePinner2.check.overload('java.lang.String', '[Ljava.security.cert.Certificate;')
            .implementation = function(hostname, certs) {
                console.log('[BYPASS-SSL] OkHttp3 CertificatePinner.check(Certificate[]) bypassed for: ' + hostname);
            };
    } catch(e) { console.log('[ERROR] OkHttp3 CertificatePinner.check(Certificate[]) failed: ' + e); }

    try {
        var CertificatePinner3 = Java.use('okhttp3.CertificatePinner');
        CertificatePinner3['check$okhttp'].implementation = function(hostname, pinsFn) {
            console.log('[BYPASS-SSL] OkHttp3 CertificatePinner.check$okhttp bypassed for: ' + hostname);
        };
    } catch(e) { console.log('[ERROR] OkHttp3 check$okhttp failed (may not apply): ' + e); }

    // 3. network_security_config pin bypass
    // AndroGoat pins cve.org with 3 SHA-256 hashes in network_security_config.xml
    try {
        var NetworkSecurityTrustManager = Java.use('android.security.net.config.NetworkSecurityTrustManager');
        NetworkSecurityTrustManager.checkPins.implementation = function(chain) {
            console.log('[BYPASS-SSL] NetworkSecurityTrustManager.checkPins bypassed');
        };
    } catch(e) { console.log('[ERROR] NetworkSecurityTrustManager.checkPins failed: ' + e); }

    try {
        var NetworkSecurityTrustManager2 = Java.use('android.security.net.config.NetworkSecurityTrustManager');
        NetworkSecurityTrustManager2.checkServerTrusted.overload('[Ljava.security.cert.X509Certificate;', 'java.lang.String')
            .implementation = function(chain, authType) {
                console.log('[BYPASS-SSL] NetworkSecurityTrustManager.checkServerTrusted bypassed');
            };
    } catch(e) { console.log('[ERROR] NetworkSecurityTrustManager.checkServerTrusted failed: ' + e); }

    try {
        var PinSet = Java.use('android.security.net.config.PinSet');
        PinSet.checkServerTrusted.implementation = function() {
            console.log('[BYPASS-SSL] PinSet.checkServerTrusted bypassed');
        };
    } catch(e) { console.log('[ERROR] PinSet.checkServerTrusted failed: ' + e); }

    // 4. X509TrustManagerExtensions
    try {
        var X509TrustManagerExtensions = Java.use('android.net.http.X509TrustManagerExtensions');
        X509TrustManagerExtensions.checkServerTrusted.implementation = function(chain, authType, host) {
            console.log('[BYPASS-SSL] X509TrustManagerExtensions.checkServerTrusted bypassed for: ' + host);
            return Java.use('java.util.ArrayList').$new();
        };
    } catch(e) { console.log('[ERROR] X509TrustManagerExtensions hook failed: ' + e); }

    // 5. Generic javax.net.ssl.X509TrustManager + HostnameVerifier override
    try {
        var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
        var SSLContext       = Java.use('javax.net.ssl.SSLContext');

        var TrustManager = Java.registerClass({
            name: 'com.auabf.TrustManager',
            implements: [X509TrustManager],
            methods: {
                checkClientTrusted: function(chain, authType) {},
                checkServerTrusted: function(chain, authType) {
                    console.log('[BYPASS-SSL] Custom X509TrustManager.checkServerTrusted bypassed');
                },
                getAcceptedIssuers: function() { return []; }
            }
        });

        var HostnameVerifier = Java.use('javax.net.ssl.HostnameVerifier');
        var CustomHostnameVerifier = Java.registerClass({
            name: 'com.auabf.HostnameVerifier',
            implements: [HostnameVerifier],
            methods: {
                verify: function(hostname, session) {
                    console.log('[BYPASS-SSL] HostnameVerifier.verify bypassed for: ' + hostname);
                    return true;
                }
            }
        });

        var sslCtx = SSLContext.getInstance('TLS');
        sslCtx.init(null, [TrustManager.$new()], null);

        var HttpsURLConnection = Java.use('javax.net.ssl.HttpsURLConnection');
        HttpsURLConnection.setDefaultSSLSocketFactory(sslCtx.getSocketFactory());
        HttpsURLConnection.setDefaultHostnameVerifier(CustomHostnameVerifier.$new());
        console.log('[BYPASS-SSL] Global TrustManager + HostnameVerifier installed');
    } catch(e) { console.log('[ERROR] Generic TrustManager hook failed: ' + e); }

    // 6. OkHttp3 — force trust all via SSLSocketFactory on builder
    try {
        var OkHttpClientBuilder = Java.use('okhttp3.OkHttpClient$Builder');
        var X509TrustManager3   = Java.use('javax.net.ssl.X509TrustManager');
        var SSLContext3          = Java.use('javax.net.ssl.SSLContext');

        var TrustAllManager = Java.registerClass({
            name: 'com.auabf.TrustAllManager',
            implements: [X509TrustManager3],
            methods: {
                checkClientTrusted: function(chain, authType) {},
                checkServerTrusted: function(chain, authType) {
                    console.log('[BYPASS-SSL] OkHttp TrustAllManager.checkServerTrusted bypassed');
                },
                getAcceptedIssuers: function() { return []; }
            }
        });

        var trustAllInstance = TrustAllManager.$new();
        var sslCtx3 = SSLContext3.getInstance('TLS');
        sslCtx3.init(null, [trustAllInstance], null);

        OkHttpClientBuilder.build.implementation = function() {
            console.log('[BYPASS-SSL] OkHttpClient.Builder.build() — injecting trust-all SSLSocketFactory');
            this.sslSocketFactory(sslCtx3.getSocketFactory(), trustAllInstance);
            this.hostnameVerifier(Java.use('javax.net.ssl.HttpsURLConnection').getDefaultHostnameVerifier());
            return this.build();
        };
    } catch(e) { console.log('[ERROR] OkHttpClient.Builder.build hook failed: ' + e); }

    // ─── EMULATOR DETECTION BYPASS ──────────────────────────────────────────

    try {
        var TelephonyManager = Java.use('android.telephony.TelephonyManager');
        TelephonyManager.getNetworkOperatorName.overload().implementation = function() {
            return "T-Mobile";
        };
        TelephonyManager.getSimOperatorName.overload().implementation = function() {
            return "T-Mobile";
        };
        TelephonyManager.getLine1Number.overload().implementation = function() {
            return "+1234567890";
        };
    } catch(e) { console.log('[ERROR] TelephonyManager hook failed: ' + e); }

    // ─── DEBUGGER DETECTION BYPASS ──────────────────────────────────────────

    try {
        var Debug = Java.use('android.os.Debug');
        Debug.isDebuggerConnected.implementation  = function() { return false; };
        Debug.waitingForDebugger.implementation   = function() { return false; };
    } catch(e) { console.log('[ERROR] Debug hook failed: ' + e); }

    console.log("[AUABF] ✓ All bypasses loaded successfully!");
});
