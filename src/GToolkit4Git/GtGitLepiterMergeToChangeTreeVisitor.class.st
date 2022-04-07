Class {
	#name : #GtGitLepiterMergeToChangeTreeVisitor,
	#superclass : #IceTreeVisitor,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtGitLepiterMergeToChangeTreeVisitor >> lepiterWorkingCopy [

	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitLepiterMergeToChangeTreeVisitor >> lepiterWorkingCopy: aLepiterWorkingCopy [

	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #accessing }
GtGitLepiterMergeToChangeTreeVisitor >> relativePathForDatabase: aDatabase [
	^ aDatabase localStoreRootDirectory asFileReference path 
			relativeTo: self lepiterWorkingCopy icebergRepository repositoryDirectory
]

{ #category : #visiting }
GtGitLepiterMergeToChangeTreeVisitor >> visitAddition: anIceAddition [ 
	self halt.
]

{ #category : #visiting }
GtGitLepiterMergeToChangeTreeVisitor >> visitDirectoryDefinition: anIceDirectoryDefinition [ 
	| directoryReference |
	directoryReference := self lepiterWorkingCopy fileSystem resolve: anIceDirectoryDefinition path.
	
	(directoryReference files anySatisfy: [ :aFile |
		aFile basename = LepiterCoreDefaults databasePropertiesBasename ])
			ifFalse: [ self visitChildrenOf: currentNode. ^ self ].
	
	self lepiterWorkingCopy databases 
		detect:  [ :aDatabase |
			(self relativePathForDatabase: aDatabase) = anIceDirectoryDefinition path ]
		ifFound: [ :aDatabase | aDatabase monitor primitiveReloadWithPageDeletion.  ^ self  ].

	self visitChildrenOf: currentNode
]

{ #category : #visiting }
GtGitLepiterMergeToChangeTreeVisitor >> visitNoModification: anIceNoModification [
	anIceNoModification definition accept: self.
]

{ #category : #visiting }
GtGitLepiterMergeToChangeTreeVisitor >> visitNonConflictingOperation: anIceNonConflictingOperation [ 
	anIceNonConflictingOperation chosenOperation accept: self.
]

{ #category : #visiting }
GtGitLepiterMergeToChangeTreeVisitor >> visitRootDefinition: anIceRootDefinition [ 
	self visitChildrenOf: currentNode
]
