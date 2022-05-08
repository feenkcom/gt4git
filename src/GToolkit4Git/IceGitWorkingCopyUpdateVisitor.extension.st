Extension { #name : #IceGitWorkingCopyUpdateVisitor }

{ #category : #'*GToolkit4Git' }
IceGitWorkingCopyUpdateVisitor >> visitFileNode: anIceFileDefinition [ 
	
	| reference |
	
	NonInteractiveTranscript stdout
		nextPutAll: 'IceGitWorkingCopyUpdateVisitor>>visitFileNode: ';
		space;
		nextPutAll: anIceFileDefinition asString;
		space;
		nextPutAll: anIceFileDefinition path asString;
		cr. 
	
	reference := repository location resolve: anIceFileDefinition path.
	
	NonInteractiveTranscript stdout
		nextPutAll: 'Repository location: ';
		space;
		nextPutAll: repository location asString;
		cr. 
	NonInteractiveTranscript stdout
		nextPutAll: 'Reference fullName: ';
		space;
		nextPutAll: reference fullName asString;
		cr. 
	
	NonInteractiveTranscript stdout
		nextPutAll: 'Reference exists: ';
		nextPutAll: reference exists asString;
		cr.
	NonInteractiveTranscript stdout
		nextPutAll: 'Parent exists: ';
		nextPutAll: reference parent exists asString;
		cr.
		
	reference parent ensureCreateDirectory.
	
	NonInteractiveTranscript stdout
		nextPutAll: 'Reference parent fullName: ';
		space;
		nextPutAll: reference parent fullName asString;
		cr. 
	NonInteractiveTranscript stdout
		nextPutAll: 'Parent after creation exists: ';
		nextPutAll: reference parent exists asString;
		cr;
		flush.
	
	reference
		ensureDelete;
		binaryWriteStreamDo: [ :writeStream |
			writeStream nextPutAll: anIceFileDefinition basicContents ].
]

{ #category : #'*GToolkit4Git' }
IceGitWorkingCopyUpdateVisitor >> visitLepiterDatabase: aDatabasDefinition [
	"A Lepiter database is automaticaly persisted to disk. This visitor does not have to perform any action here."
]
