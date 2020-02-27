#!/usr/bin/env bash
if [[ -f "pom.xml" ]]; then
    mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec
else
    echo "   --------------------------------- "
    echo "  [ Go inside a maven project first ]"
    echo "   --------------------------------- "
    echo "                \\"
    echo "                 \\"
    echo "                    :                                 :       "
    echo "                  :                                   :       "
    echo "                  :  RRVIttIti+==iiii++iii++=;:,       :      "
    echo "                  : IBMMMMWWWWMMMMMBXXVVYYIi=;:,        :     "
    echo "                  : tBBMMMWWWMMMMMMBXXXVYIti;;;:,,      :     "
    echo "                  t YXIXBMMWMMBMBBRXVIi+==;::;::::       ,    "
    echo "                 ;t IVYt+=+iIIVMBYi=:,,,=i+=;:::::,      ;;   "
    echo "                 YX=YVIt+=,,:=VWBt;::::=,,:::;;;:;:     ;;;   "
    echo "                 VMiXRttItIVRBBWRi:.tXXVVYItiIi==;:   ;;;;    "
    echo "                 =XIBWMMMBBBMRMBXi;,tXXRRXXXVYYt+;;: ;;;;;    "
    echo "                  =iBWWMMBBMBBWBY;;;,YXRRRRXXVIi;;;:;,;;;=    "
    echo "                   iXMMMMMWWBMWMY+;=+IXRRXXVYIi;:;;:,,;;=     "
    echo "                   iBRBBMMMMYYXV+:,:;+XRXXVIt+;;:;++::;;;     "
    echo "                   =MRRRBMMBBYtt;::::;+VXVIi=;;;:;=+;;;;=     "
    echo "                    XBRBBBBBMMBRRVItttYYYYt=;;;;;;==:;=       "
    echo "                     VRRRRRBRRRRXRVYYIttiti=::;:::=;=         "
    echo "                      YRRRRXXVIIYIiitt+++ii=:;:::;==          "
    echo "                      +XRRXIIIIYVVI;i+=;=tt=;::::;:;          "
    echo "                       tRRXXVYti++==;;;=iYt;:::::,;;          "
    echo "                        IXRRXVVVVYYItiitIIi=:::;,::;          "
    echo "                         tVXRRRBBRXVYYYIti;::::,::::          "
    echo "                          YVYVYYYYYItti+=:,,,,,:::::;         "
    echo "                          YRVI+==;;;;;:,,,,,,,:::::::    "
fi

exit 1
