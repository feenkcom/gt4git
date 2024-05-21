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
	messageBytes := self
		forPharo11OrNewer: [
			"Since Pharo11, commit_message returns an ExternalAddress"
			message bytesFromCString ]
		forPharo10:  [
			"In Pharo10, commit_message returns a string"
			message isWideString ifTrue:
				[ 1 to: message size do: [ :i |
					(message at: i) codePoint > 128 ifTrue:
						[ message at: i put: $? ] ] ].
			
			message asByteString asByteArray ].
	
	"git cannot always be trusted to return the right encoding"
	^ [ messageBytes decodeWith: encoding ]
		  on: ZnCharacterEncodingError
		  do: [ 
		  	self 
		  		forPharo11OrNewer: [ messageBytes asString ]
		  		forPharo10: [ message asByteString ] ]
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
