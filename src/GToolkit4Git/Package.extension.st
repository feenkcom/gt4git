Extension { #name : #Package }

{ #category : #'*GToolkit4Git' }
Package >> repository [
	^ GtGitRepository forPackage: self
]
