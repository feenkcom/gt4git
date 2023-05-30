Extension { #name : #Object }

{ #category : #'*GToolkit4Git' }
Object class >> repository [
	^ GtGitRepository forClass: self
]
