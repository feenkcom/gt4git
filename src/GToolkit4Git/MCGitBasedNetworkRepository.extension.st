Extension { #name : #MCGitBasedNetworkRepository }

{ #category : #'*GToolkit4Git' }
MCGitBasedNetworkRepository >> createIcebergRepositoryFor: remoteUrl [
	<gtPharoPatch: #Pharo>

	| builder repository |
	builder := IceRepository repositoryClass creatorClass new 
		url: remoteUrl;
		subdirectory: repoPath;
		commitishName: self projectVersion;
		ensureProjectFile;
		yourself.

	[ repository := builder createRepository ]
		on: IceDuplicatedRepository 
		do: [ :e | 
			e resignalAs: (IceMetacelloDuplicatedNotification new
				builder: builder;
				yourself)  ].

	repository register.

	^ repository
]
