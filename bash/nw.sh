
function list_ports() {
    lsof -PiTCP -sTCP:LISTEN
}


main() {
    if [ $# -lt 1 ]; then
        usage
        exit 1
    fi

    subtask=$1

    case $subtask in
    ports)
        list_ports "${@:2}"
        ;;
    help)
        echo "Creates a ssh tunnel to a specified host"
        usage
        exit 0
        ;;
    *)
        echo "Wrong option"
        usage
        exit 1
        ;;
    esac
}

main "$@"
