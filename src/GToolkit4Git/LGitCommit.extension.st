Extension { #name : #LGitCommit }

{ #category : #'*GToolkit4Git' }
LGitCommit >> message [
	<gtPharoPatch: #Pharo>
	
	| encoding message messageBytes |
	encoding := (self commit_message_encoding: self)
		            ifNil: [ ZnCharacterEncoder utf8 ]
		            ifNotNil: [ :anEncodingName | 
		            ZnCharacterEncoder newForEncoding: anEncodingName ].
	message := self commit_message: self.
	"Since Pharo11, commit_message returns an ExternalAddress"
	messageBytes := message bytesFromCString .
	
	"git cannot always be trusted to return the right encoding"
	^ [ messageBytes decodeWith: encoding ]
		  on: ZnCharacterEncodingError
		  do: [ messageBytes asString ]
]

{ #category : #'*GToolkit4Git' }
LGitCommit >> revert [
	^ self ffiCallSafely: #(
		int git_revert(
			LGitRepository repository, 
			LGitCommit self, 
			NULL))
		options: #()
]
