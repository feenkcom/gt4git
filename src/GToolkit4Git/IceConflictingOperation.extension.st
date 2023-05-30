Extension { #name : #IceConflictingOperation }

{ #category : #'*GToolkit4Git' }
IceConflictingOperation >> isUnresolvedConflict [
	^ self isResolved not
]
