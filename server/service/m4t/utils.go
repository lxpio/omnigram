package m4t

func UpdateRemote(addr string) error {
	return remoteServer.update(addr)
}
