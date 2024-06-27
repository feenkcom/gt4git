Class {
	#name : #IceGitCliFileWriter,
	#superclass : #IceMetadatalessFileTreeWriter,
	#traits : 'TIceRepositoryWriter',
	#classTraits : 'TIceRepositoryWriter classTrait',
	#category : #GToolkit4Git
}

{ #category : #accessing }
IceGitCliFileWriter class >> description [

	^ 'Tonel'
]

{ #category : #accessing }
IceGitCliFileWriter class >> directoryNameFor: aPackage [
	^ aPackage name, '.package'
]
