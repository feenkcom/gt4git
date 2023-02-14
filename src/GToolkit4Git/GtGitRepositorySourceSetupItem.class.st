Class {
	#name : #GtGitRepositorySourceSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositorySourceSetupItem class >> priority [
	^ 1
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupDefaultDirectoryAction ];
		cr.
	aStream next
		appendingAdornment: [ self setupSourceDirectoryAction ];
		putAll: ' or '.
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> isExecuted [
	^ self repository repository project isUnborn not
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> message [
	^ 'Create metadata'
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> setupDefaultDirectoryAction [
	^ BrButton new
		label: 'Create a default source directory';
		aptitude: BrGlamorousButtonWithLabelAptitude;
		action: [ | model |
			model := IceBasicProject onRepository: self repository repository.
			(self repository repository repositoryDirectory / 'src')
				ensureCreateDirectory.
			model sourceDirectory: 'src'.
			model fileFormat: IceLibgitTonelWriter.
			self assert: model repositoryProperties fileFormat = IceLibgitTonelWriter.	"Set the project in the repository"
			self repository workingCopy project: model.
			self repository announceRepositoryModified ]
]

{ #category : #accessing }
GtGitRepositorySourceSetupItem >> setupSourceDirectoryAction [
	^ self
		actionButtonLabelled: 'Create a custom source directory'
		withDropdownContent: [ :aButton | 
			(GtGitRepairProject new
				repository: self repository repository;
				dropdown: aButton) repairStencil ]
]
