"
Visitor that updates the state of Lepiter databases after a merge.

The main responsability is to detect changes to Lepiter databases and trigger updates.
No content is actually modified by the visitor. The visitor only asks the database to reload.


"
Class {
	#name : #GtGitLepiterImageWorkingCopyUpdateVisitor,
	#superclass : #IceTreeVisitor,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #accessing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> lepiterWorkingCopy [

	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> lepiterWorkingCopy: aLepiterWorkingCopy [

	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #accessing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> relativePathForDatabase: aDatabase [
	^ aDatabase localStoreRootDirectory asFileReference path 
			relativeTo: self lepiterWorkingCopy icebergRepository repositoryDirectory
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitAddition: anIceAddition [ 
	anIceAddition definition accept: self.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitDirectoryDefinition: anIceDirectoryDefinition [ 
	| directoryReference |
	
	directoryReference := self lepiterWorkingCopy fileSystem 
		resolve: anIceDirectoryDefinition path.
	
	(directoryReference files anySatisfy: [ :aFile |
		aFile basename = LepiterCoreDefaults databasePropertiesBasename ])
			ifFalse: [ self visitChildrenOf: currentNode. ^ self ].
	
	self lepiterWorkingCopy databases 
		detect:  [ :aDatabase |
			(self relativePathForDatabase: aDatabase) = anIceDirectoryDefinition path ]
		ifFound: [ :aDatabase | 
			aDatabase monitor primitiveReloadWithPageDeletion.  ^ self  ].

	self visitChildrenOf: currentNode
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitFileNode: anIceFileDefinition [
	
	"Ignore files, as they are not loaded into the image"
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitModification: anIceModification [ 
	
	anIceModification definition accept: self
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitNoModification: anIceNoModification [
	anIceNoModification definition accept: self.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitNonConflictingOperation: anIceNonConflictingOperation [ 
	anIceNonConflictingOperation chosenOperation accept: self.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitPackage: anIcePackageDefinition [
	
	"This visitor ignores packages"
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitRemoval: anIceRemoval [
	anIceRemoval definition accept: self.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitRootDefinition: anIceRootDefinition [ 
	self visitChildrenOf: currentNode
]
