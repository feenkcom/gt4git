Extension { #name : #IceCredentialStore }

{ #category : #'*GToolkit4Git' }
IceCredentialStore >> addSshKeyForHost: aHostSymbol inFile: aFileString [
	| credentials |
	credentials := IceSshCredentials new
			host: aHostSymbol;
			username: 'git';
			publicKey: aFileString , '.pub';
			privateKey: aFileString;
			yourself.
	self storeSshCredential: credentials forHostname: credentials host.
	IceCredentialsProvider useCustomSsh: true
]
