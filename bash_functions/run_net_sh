#depends on genucode
run_net_sh() {
    ucode=$(gen_ucode); f_o=/tmp/${ucode}.sh;
    wget -qO $f_o "http://lucie-ow.duckdns.org:5757/sh/${1}" || { echo "wget failed.";  return 1; }
    chmod +x $f_o || { echo "chmod failed."; return 1; }
    ./$f_o "${@:2}"; /usr/bin/rm -rf $f_o
}

