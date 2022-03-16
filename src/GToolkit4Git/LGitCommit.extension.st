Extension { #name : #LGitCommit }

{ #category : #'*GToolkit4Git' }
LGitCommit >> message [

	| encoding |
	encoding := (self commit_message_encoding: self)
		            ifNil: [ ZnCharacterEncoder utf8 ]
		            ifNotNil: [ :anEncodingName | 
		            ZnCharacterEncoder newForEncoding: anEncodingName ].
	^ (self commit_message: self) asByteArray decodeWith: encoding
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
