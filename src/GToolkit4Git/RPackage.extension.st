Extension { #name : #RPackage }

{ #category : #'*GToolkit4Git' }
RPackage >> repository [
	^ GtGitRepository forPackage: self
]
