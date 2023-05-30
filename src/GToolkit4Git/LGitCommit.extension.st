Extension { #name : #LGitCommit }

{ #category : #'*GToolkit4Git' }
LGitCommit >> message [

	| encoding message |
	encoding := (self commit_message_encoding: self)
		            ifNil: [ ZnCharacterEncoder utf8 ]
		            ifNotNil: [ :anEncodingName | 
		            ZnCharacterEncoder newForEncoding: anEncodingName ].
	message := self commit_message: self.
	message isWideString ifTrue:
		[ 1 to: message size do: [ :i |
			(message at: i) codePoint > 128 ifTrue:
				[ message at: i put: $? ] ] ].
	"git cannot always be trusted to return the right encoding"
	^ [ message asByteString asByteArray decodeWith: encoding ]
		  on: ZnCharacterEncodingError
		  do: [ message asByteString ]
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
