"
Visitor that updates the state of Lepiter databases after a merge.

The main responsability is to detect changes to Lepiter databases and trigger updates.
No pages or other content is directly modified by the visitor. The visitor only asks the 
working copy to reload or remove databases.

The visitor can either visit a merge tree containing merge operations ({{gtClass:IceOperationMerge}}) or a diff tree containing change operations ({{gtClass:IceOperation}}). 
"
Class {
	#name : #GtGitLepiterImageWorkingCopyUpdateVisitor,
	#superclass : #IceTreeVisitor,
	#instVars : [
		'lepiterWorkingCopy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #testing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> isLepiterDatabaseDefinition: anIceDefinition [ 
	| directoryReference |
	
	anIceDefinition class = IceDirectoryDefinition ifFalse: [ ^ false ].
	
	directoryReference := self lepiterWorkingCopy fileSystem 
		resolve: anIceDefinition path.
	
	^ directoryReference files anySatisfy: [ :aFile |
		aFile basename = LepiterCoreDefaults databasePropertiesBasename ]
]

{ #category : #testing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> isLoadedLepiterDatabaseDefinition: anIceDefinition [ 
	^ (self isLepiterDatabaseDefinition: anIceDefinition) and: [
		self isRegisteredLepiterDatabaseDefinition: anIceDefinition ]
]

{ #category : #testing }
GtGitLepiterImageWorkingCopyUpdateVisitor >> isRegisteredLepiterDatabaseDefinition: anIceDefinition [ 
	anIceDefinition class = IceDirectoryDefinition ifFalse: [ ^ false ].
	
	^ self lepiterWorkingCopy databases 
		anySatisfy: [ :aDatabase |
			(self relativePathForDatabase: aDatabase) = anIceDefinition path ]
]

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

{ #category : #updating }
GtGitLepiterImageWorkingCopyUpdateVisitor >> removeLepiterDatabaseForDefinition: anIceDirectoryDefinition [

	self 
		withDatabaseForDefinition: anIceDirectoryDefinition 
		do: [ :aDatabase | 
			self lepiterWorkingCopy removeDatabase: aDatabase ]
	
]

{ #category : #updating }
GtGitLepiterImageWorkingCopyUpdateVisitor >> updateDatabaseForDefiniton: anIceDirectoryDefinition [

	self 
		withDatabaseForDefinition: anIceDirectoryDefinition 
		do: [ :aDatabase | 
			self lepiterWorkingCopy updateContentForDatabase: aDatabase ]
]

{ #category : #'visiting - operations' }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitAddition: anIceAddition [ 
	anIceAddition definition accept: self.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitDirectoryDefinition: anIceDirectoryDefinition [ 
	
	(self isLoadedLepiterDatabaseDefinition: anIceDirectoryDefinition) ifFalse: [ 
		^ self visitChildrenOf: currentNode ].
	
	self updateDatabaseForDefiniton: anIceDirectoryDefinition.
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitFileNode: anIceFileDefinition [
	
	"Ignore files, as they are not loaded into the image"
]

{ #category : #'visiting - operations' }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitModification: anIceModification [ 
	
	anIceModification definition accept: self
]

{ #category : #'visiting - operations' }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitNoModification: anIceNoModification [
	anIceNoModification definition accept: self.
]

{ #category : #'visiting - merge tree' }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitNonConflictingOperation: anIceNonConflictingOperation [ 
	anIceNonConflictingOperation chosenOperation accept: self
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitPackage: anIcePackageDefinition [
	
	"This visitor ignores packages"
]

{ #category : #'visiting - operations' }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitRemoval: anIceRemoval [
	
	(self isRegisteredLepiterDatabaseDefinition: anIceRemoval definition) ifTrue: [ 
		^ self removeLepiterDatabaseForDefinition: anIceRemoval definition ].

	self visitChildrenOf: currentNode
]

{ #category : #visiting }
GtGitLepiterImageWorkingCopyUpdateVisitor >> visitRootDefinition: anIceRootDefinition [ 
	self visitChildrenOf: currentNode
]

{ #category : #utils }
GtGitLepiterImageWorkingCopyUpdateVisitor >> withDatabaseForDefinition: anIceDefinition do: aBlock [

	self lepiterWorkingCopy databases 
		detect:  [ :aDatabase |
			(self relativePathForDatabase: aDatabase) = anIceDefinition path ]
		ifFound: [ :aDatabase | 
			aBlock value: aDatabase ]
		ifNone: [ Error signal: 'Database not found' ]
		
	
]
