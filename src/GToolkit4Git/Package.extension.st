Extension { #name : #Package }

{ #category : #'*GToolkit4Git' }
Package >> mcPackage [
	"Normally the corresponding MCPackage should exist, but in certain cases it could happen that it does not"
	<gtPharoPatch: #Pharo12>
	
	^ self mcWorkingCopy 
		ifNil: [ MCPackage named: self name ]
		ifNotNil: [ :workingCopy | workingCopy package ].
	
]

{ #category : #'*GToolkit4Git' }
Package >> repository [
	^ GtGitRepository forPackage: self
]
