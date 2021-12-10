Extension { #name : #IceGitCommit }

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtChangesFor: aView [
	<gtView>
	^ (IceDiff from: self to:self parent) gtViewInspectorDiffFor: aView
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtFileSystemItemsFor: aView [
	<gtView>
	^ (self fileSystem gtItemsFor: aView)
		title: 'File system' translated;
		priority: 70
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtViewLepitereDatabasesFor: aView [
	<gtView>
	^ aView forward 
		title: 'Lepiter Databases';
		object: [ self lepiterDatabases ];
		view: #gtItemsFor:
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> includesKnowledgeWithId: anUuid [
	^ self lepiterDatabases anySatisfy: [ :anInCommitDatabase |
		anInCommitDatabase database uuid = anUuid ]
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> lepiterDatabases [
	| databaseFolders |
	databaseFolders := self fileSystem children 
		select: [ :aFileOrFolder | aFileOrFolder isLepiterDatabaseFolder ].
	^ databaseFolders collect: [ :aFolder |
	 	GtLepiterInsideCommitDatabase new
	 		commit: self;
	 		localRoot: aFolder ]
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> snapshotForKnowledgeWithId: anUuid [
	| inCommitDatabase |
	inCommitDatabase := self lepiterDatabases detect: [ :anInCommitDatabase |
		anInCommitDatabase database uuid = anUuid ].
	^ GtLepiterDatabaseSnapshot fromDatabase: inCommitDatabase database.
]
