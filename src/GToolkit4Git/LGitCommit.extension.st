Extension { #name : #LGitCommit }

{ #category : #'*GToolkit4Git' }
LGitCommit >> message [
	
	| encoding |
	encoding := self commit_message_encoding: self.
	^ (self commit_message: self) asByteArray decodeWith: (ZnCharacterEncoder newForEncoding: encoding)
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
