Class {
	#name : #GtGitRepositoryDatabaseSetupItem,
	#superclass : #GtGitRepositorySetupItem,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem class >> priority [
	^ 4
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> buildActionsIn: aStream [
	aStream next
		appendingAdornment: [ self setupLepiterDatabaseAction ];
		cr.
	aStream next
		appendingAdornment: [ self setupCustomLepiterDatabaseAction ];
		putAll: ' or '
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> isExecuted [
	^ self repository hasDatabase
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> isRequired [
	^ false
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> message [
	^ 'Add Lepiter Knowledge Base'
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> setupCustomLepiterDatabaseAction [
	^ self
		actionButtonLabelled: 'Create custom directory'
		withDropdownContent: [ :aButton | 
			BrFileSelector new
				vExact: 250;
				hExact: 400;
				folder: self repository repository repositoryDirectory;
				addAptitude: BrGlamorousWithVerticalResizerAptitude
						+ BrGlamorousWithHorizontalResizerAptitude
						+ BrGlamorousWithHorizontalResizerAptitude new beLeft;
				fileFilterBlock: [ :aFile | aFile isDirectory ];
				okAction: [ :aDirectory :_ | 
					aButton fireEvent: BrDropdownHideWish new.
					self repository addNewDatabaseInDirectory: aDirectory ];
				buttonLabel: 'Choose';
				padding: (BlInsets all: 10) ]
]

{ #category : #accessing }
GtGitRepositoryDatabaseSetupItem >> setupLepiterDatabaseAction [
	^ BrButton new
		label: 'Create default Lepiter directory';
		aptitude: BrGlamorousButtonWithLabelAptitude;
		action: [ self repository
				addNewDatabaseInDirectory: self repository repository repositoryDirectory / 'lepiter' ]
]
