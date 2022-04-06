Extension { #name : #IceGitCommit }

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtChangesFor: aView [
	<gtView>
	^ aView forward
		title: 'Changes';
		object: [ IceDiff from: self to:self parent ];
		view: #gtViewInspectorDiffFor:
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> gtFileSystemItemsFor: aView [
	<gtView>
	^ aView forward
		title: 'File system' translated;
		priority: 70;
		object: [ self fileSystem ];
		view: #gtItemsFor:
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
IceGitCommit >> resolveDelta: aGtDiffDelta [
	^ (self fileSystem resolve: aGtDiffDelta oldFileRelative) asFileReference
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> revert [
	^ self libgitCommit revert = 0
]

{ #category : #'*GToolkit4Git' }
IceGitCommit >> snapshotForKnowledgeWithId: anUuid [
	| inCommitDatabase |
	inCommitDatabase := self lepiterDatabases detect: [ :anInCommitDatabase |
		anInCommitDatabase database uuid = anUuid ].
	^ GtLepiterDatabaseSnapshot fromDatabase: inCommitDatabase database.
]
