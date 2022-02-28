Extension { #name : #IceWorkingCopyPatcherVisitor }

{ #category : #'*GToolkit4Git' }
IceWorkingCopyPatcherVisitor >> visitFileNode: anIceFileDefinition [

	| reference |
	reference := repository location resolve: anIceFileDefinition path.
	reference binaryWriteStreamDo: [ :s | 
		s truncate.
		s nextPutAll: anIceFileDefinition contents ]
]

{ #category : #'*GToolkit4Git' }
IceWorkingCopyPatcherVisitor >> visitLepiterPage: aPageDefinition [
	aPageDefinition asMCDefinition
]
